# WSL configuration.
#
# Used for `nixos-wsl`, which is not a real machine: it is the entry point for
# building a NixOS image that boots inside Windows Subsystem for Linux.
{
  ...
}:

{
  imports = [
    ../../modules
  ];

  networking.resolvconf.enable = false;
}
