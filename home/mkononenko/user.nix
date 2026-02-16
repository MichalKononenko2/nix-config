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
    vscode
    elan
    vlc
    dropbox
    evince
    helix
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

  programs.helix = {
    enable = true;
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
  };

  home.stateVersion = "25.05";
}

