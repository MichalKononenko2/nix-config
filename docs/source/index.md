# Nix-Config

Documentation for [the `nix-config` repository](https://github.com/MichalKononenko2/nix-config),
which holds Michal Kononenko's operating system configuration.

This site is generated from the configuration itself. Module options are
rendered straight out of the NixOS module system, so the documentation cannot
drift away from the options it describes.

## Building the docs

```sh
nix build .#docs
```

The result is a directory named `nix-config-docs` inside `./result`. To build
and preview locally with live reload:

```sh
nix build .#docs && python -m http.server -d ./result/nix-config-docs
```

`nix flake check` builds the docs too, so a pull request that breaks the
documentation will fail CI on its own.

```{toctree}
:maxdepth: 2
:caption: Modules

modules/index
```

```{toctree}
:maxdepth: 2
:caption: Hosts

hosts/index
```

```{toctree}
:maxdepth: 1
:caption: Repository

architecture
deployment
troubleshooting
```

## Indices

* {ref}`genindex`
* {ref}`nix-optionsindex`
