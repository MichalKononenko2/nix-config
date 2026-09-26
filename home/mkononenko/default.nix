# Home-manager configuration for the interactive user account.
#
# Deliberately minimal. The bulk of the toolchain is declared on the NixOS side
# in `configurations/artax/default.nix` and will move here in a later stage;
# this file exists to prove the home-manager plumbing works and to hold the
# handful of settings that are genuinely per-user.
#
# `osConfig` is injected by the flake (see `homeFor` in flake.nix) so that a
# home configuration can read its host's system configuration.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

{
  home.username = "mkononenko";
  home.homeDirectory = "/home/mkononenko";
  home.stateVersion = "25.05";

  # home-manager tracks release-26.05 while nixpkgs tracks nixos-unstable, so
  # every build would otherwise print a version-mismatch warning. The
  # mismatch is a deliberate choice, not an oversight; revisit it if
  # home-manager evaluation starts failing on nixpkgs API changes.
  home.enableNixpkgsReleaseCheck = false;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "MichalKononenko2";
      user.email = "michalkononenko@gmail.com";
      init.defaultBranch = "master";
    };
  };

  # Proves that `osConfig` is threaded through from the host: the shell prompt
  # can tell you which machine you are on.
  home.sessionVariables = {
    NIX_CONFIG_HOST = osConfig.networking.hostName;
  };
}
