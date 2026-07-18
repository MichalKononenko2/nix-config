# Modules

A module is a nix expression adhering to a certain convention.
It is a function that declares options and config values.
An example is shown below

```nix
{ config, libs, pkgs, ... }:
{
    options.myapp.enable = lib.mkEnableOption "myapp";

    config = lib.mkIf config.myapp.enable {
        services.myapp.package = pkgs.myapp;
        users.users.alice.extraGroups = [ "myApp" ];
    };
}
```

The module system then grabs all the modules recursively and
merges them into a single object.

