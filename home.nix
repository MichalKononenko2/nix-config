{ config, pkgs, lib, ...}:
{
  home.username = "mkononenko";
  home.homeDirectory = lib.mkForce "/home/mkononenko";

  home.packages = with pkgs; [
    neofetch # Obviously needed for flexing reasons
    nnn      # Neato terminal file manager
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
    transmission_4-qt
    vscode
    elan
    vlc
    dropbox
    evince
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "MichalKononenko2";
      user.email = "michalkononenko@gmail.com";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  home.stateVersion = "25.05";
}

