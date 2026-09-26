# Architecture

The top-level nix config is exposed in ``flake.nix``. This flake exposes a series
of configurations found in the ``configurations`` directory.  A ``configuration`` is
a composition of ``hosts`` and ``modules``. A ``host`` represents a physical machine.
``modules`` contain components exposed via nix options. ``configurations`` are where
these two items come together.

## Layout

```
flake.nix          outputs, and the only file that knows every host exists
modules/           reusable, option-owning NixOS modules
  baseline.nix       mkononenko.nix.*        Nix features, unfree, cachix
  desktop/           mkononenko.desktop.*    XMonad + XFCE, peripherals
  server/            mkononenko.server.*     headless: SSH, zram, tmp
  users/             mkononenko.user.*       NixOS-side accounts
  agenix/            mkononenko.agenix.*     secret management
  agent/             mkononenko.agent.*      headless OpenCode
secrets/           age ciphertext (committed) and the encrypt workflow
configurations/    per-host composition, imported by flake.nix
  artax/
  tianma1/
hosts/             per-machine facts
  artax.nix          hardware scan, disks, bootloader
  tianma1/
  wsl/               wsl settings
home/              home-manager configurations
  mkononenko/        git, shell, direnv
docs/              this site
scripts/           repository maintenance checks
```

Three axes, and what belongs on each:

| Directory        | Question it answers                     | Changes when            |
| ---------------- | --------------------------------------- | ----------------------- |
| `hosts/`         | What machine is this?                   | You buy or rebuild a PC |
| `configurations/`| Which modules does this machine switch on? | Never — it is a few lines per switch |
| `modules/`       | What does this capability *do*?         | Never, for a given host |
| `home/`          | What does this *person* have?           | A person changes their mind |

## Where secrets fit

A secret in a Nix expression is a
secret in the Nix store. The Nix store is world-readable and cached in
places you do not control.

So `secrets/` holds age ciphertext, which is safe to commit, and the plaintext
lives only in an age identity that is not in this repository. Modules declare
*that* they need a secret; they never declare its value. See
{doc}`modules/agenix` and `secrets/README.md`.

## The system / user split

`modules/` and `home/` are different systems with different lifecycles, and the
tension between them is resolved by keeping them in different directories that
meet in exactly one place.

- `modules/` is NixOS. It needs root. It decides what a machine *is*.
- `home/` is home-manager. It needs no privileges. It decides what a person
  has.

The two are joined in `homeFor` in `flake.nix`, which builds a home-manager
configuration for a named user directory and injects that host's `osConfig`:

```nix
homeFor =
  name: host: system:
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    extraSpecialArgs = { osConfig = self.nixosConfigurations.${host}.config; };
    modules = [ ./home/${name} ];
  };
```

`osConfig` is passed explicitly rather than by embedding home-manager into
NixOS, so that a home configuration remains evaluable on its own. That is what
lets `checks.home-manager` catch a broken `home/` file in CI before it is
deployed to a machine.

The consequence worth remembering: **a setting belongs in `home/` if it
follows the person, and in `modules/` if it follows the machine.** Git
configuration follows the person. A font package follows the machine.

## How the documentation stays honest

Three mechanisms, in increasing order of strictness.

1. **The `declared in self` filter.** `sphinxcontrib-nixdomain` renders only
   options declared inside this repository. Anything assigned inline in a host
   file is silently absent, so there is no temptation to document options
   Nixpkgs already documents.
2. **Isolation.** The docs build evaluates `modules/` on their own, with no
   host. A module that depends on a host-supplied `_module.args` breaks the
   build rather than producing subtly wrong documentation.
3. **`checks.docs-coverage`.** A script walks `modules/` and fails if any
   module has no page under `docs/source/modules/`. This is the only one that
   catches an undocumented module, because the filter in (1) cannot tell the
   difference between a module that is documented and one that was forgotten.

Run it directly with:

```sh
nix run .#docs-coverage
```

## Version pinning

`nixpkgs` tracks `nixos-unstable`. `home-manager` tracks `release-26.05`,
which is behind unstable and therefore produces a version-mismatch warning on
every home-manager build. The mismatch is suppressed with
`home.enableNixpkgsReleaseCheck`; revisit it if home-manager evaluation starts
failing in ways that look like nixpkgs API changes.
