# This is the configuration file for NixOS for Windows Subsystem for Linux (WSL)

{ config, lib, pkgs, ... }:
{

  imports = [
    <nixos-wsl/modules> # Import the NixOS-WSL modules
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  system.stateVersion = "25.05";
}

