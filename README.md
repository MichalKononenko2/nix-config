# Nixos-Config

Michal Kononenko's operating system configuration, built with Nix flakes.

## Documentation

See <https://michalkononenko2.github.io/nix-config/> for the documentation,
which is generated from this repository's own module options by
[sphinxcontrib-nixdomain](https://sphinxcontrib-nixdomain.readthedocs.io/).

```sh
nix build .#docs   # -> ./result/nix-config-docs
nix flake check   # evaluates every host, builds the docs, checks doc coverage
```

## Directory structure

| Directory         | Contents                                                          |
| ----------------- | ----------------------------------------------------------------- |
| `flake.nix`       | Every output: hosts, modules, packages, checks, formatter          |
| `modules/`        | Reusable, option-owning NixOS modules. The documentation target.   |
| `configurations/` | Per-host composition: which modules a machine switches on           |
| `hosts/`          | Per-machine facts: disks, bootloader, hardware                     |
| `home/`           | [home-manager](https://github.com/nix-community/home-manager) configurations |
| `docs/`           | Sphinx sources for this site                                       |
| `scripts/`        | Repository maintenance checks                                      |

The dividing line between `modules/` and `home/` is the system/user split:
`modules/` is NixOS and needs root, `home/` is home-manager and does not. A
setting belongs in `home/` if it follows the person, and in `modules/` if it
follows the machine.

See [the architecture notes](docs/source/architecture.md) for why modules
declare options rather than assigning them, and how that makes the
documentation generate itself.

