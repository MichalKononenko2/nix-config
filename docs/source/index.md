
# Nix-Config documentation

```{default-domain} nix
```

## Building the Docs

Use ``nix build .#docs`` to build the documentation.
This invokes the flakes feature in nix, and points to the ``docs`` package in
this directory's ``flake.nix`` for building.

## Repository Structure

``flake.nix`` declares the ``artax`` system.

Artax is my personal computer.


It also declares the ``docs`` package.

```{include} ./deployment.md
```

```{include} ./troubleshooting.md
```


## Automodule

```{automodule} 
```

## Autolibrary

```{autolibrary}
```


# Indices and tables

* {ref}`genindex`
* {ref}`nix-optionsindex`

