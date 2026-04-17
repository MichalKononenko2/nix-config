
# Nix-Config documentation

```{default-domain} nix
```

## Building the Docs

Use ``nix build .#docs`` to build the documentation.

## Repository Structure

``flake.nix`` declares the ``artax`` and the ``tianma1`` system.

Artax is my personal computer.

Tianma1 is a VPS instance running on Hetzner. 

It also declares the ``docs`` package.

```{include} ./deployment.md
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

