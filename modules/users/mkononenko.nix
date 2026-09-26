# User account: mkononenko.
#
# The NixOS-side account definition. User-specific packages and dotfiles that
# live in home-manager remain in `home/mkononenko/`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mkononenko.user.mkononenko;
in
{
  options.mkononenko.user.mkononenko = {
    enable = lib.mkEnableOption "the mkononenko user account";

    description = lib.mkOption {
      type = lib.types.str;
      default = "Michal Kononenko";
      description = "GECOS description for the user.";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "networkmanager"
        "wheel"
        "bluetooth"
      ];
      description = "Groups the user belongs to.";
    };

    shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bash;
      description = "Login shell.";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        fastfetch
        brave
        htop
        inkscape
        gimp
        darktable
        cmatrix
        zoom-us
        spotify
        pamixer
        direnv
        nix-direnv
        vscode
        elan
        tor-browser
        vlc
        dropbox
        evince
        zip
        usbutils
        traceroute
        opencode
      ];
      description = "System packages installed for this user.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.mkononenko = {
      isNormalUser = true;
      description = cfg.description;
      extraGroups = cfg.extraGroups;
      shell = cfg.shell;
      packages = cfg.packages;
    };
  };
}
