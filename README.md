# Nixos-Config

## Documentation

The /docs directory contains the configuration's Sphinx docs.
Build the documentation using

```nix
nix build .#docs
```

This invokes the flakes feature in nix, and points to the ``docs`` package
in this directory's ``flake.nix`` for building.

## Directory Structure

Home - contains user-specific configuration using home-manager.
Hosts - contains hardware configuration nixes for each supported machine
Configurations - contains portable configurations for each host

