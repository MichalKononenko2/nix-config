# Modules

Reusable, option-owning NixOS modules.

A file in `modules/` is a *module* in the strict sense: it **declares options**
rather than assigning Nixpkgs options directly. That distinction is not
pedantry — it is the reason this documentation exists.

## Why declaring options matters

The documentation is built with
[sphinxcontrib-nixdomain](https://sphinxcontrib-nixdomain.readthedocs.io/),
which renders NixOS module options. By default it keeps only options that are
*visible* **and** *declared inside this repository*:

> `filters` — By default, keep only visible options that are declared in the
> `self` source.

So a configuration that assigns Nixpkgs options inline is invisible here. Its
options are declared upstream, in Nixpkgs, and they are already documented at
[nixos.org](https://nixos.org/nixos/options.html).

Declaring an option is what buys you a rendered description, a type, a default
value, an example, and a link to the line of source that defines it. The
convention that follows from this:

> One option namespace per module. Never assign an option from a module that
> does not declare it.

## Conventions

- **Namespace.** Options live under a single top-level `mkononenko` namespace,
  subdivided by concern: `mkononenko.nix`, `mkononenko.server`,
  `mkononenko.desktop`, `mkononenko.agent`, `mkononenko.user`.
- **Descriptions are Markdown.** Option descriptions are rendered as Markdown
  by the Sphinx build, so use plain backticks for code and avoid the
  `{option}` / `{file}` cross-reference roles used in the NixOS manual — they
  would appear literally here.
- **No host-supplied arguments.** Every module must evaluate without the
  `_module.args` a host would normally provide — no `inputs`, no `osConfig`.
  The documentation build imports these modules in isolation, without a host,
  and a module that reaches for a host-supplied argument breaks the docs.
- **`enable` flags.** Anything a host can turn on and off gets
  `lib.mkEnableOption`.

## Adding a module

1. Add `modules/<name>.nix` declaring its options.
2. List it in `modules/default.nix`.
3. Add it to the `nixosModules` attribute set in `flake.nix`.
4. Add a page under `docs/source/modules/` — this is enforced by
   `checks.docs-coverage`, described in {doc}`../architecture`.

## Module pages

```{toctree}
:maxdepth: 1

baseline
desktop
server
agenix
agent
users/mkononenko
```
