{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home.username = "mkononenko";
  home.homeDirectory = lib.mkForce "/home/mkononenko";

  home.packages = with pkgs; [
    neofetch # Obviously needed for flexing reasons
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
    settings.theme = "darcula-solid";
    extraPackages = with pkgs; [ nixd ];
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
        }
      ];
      language-server = {
        nixd = {
          command = "nixd";
          args = [ "--semantic-tokens=true" ];
          config.nixd =
            let
              myFlake = ''(builtins.getFlake "/etc/nixos")'';
              nixosOpts = "${myFlake}.nixosConfigurations.${osConfig.networking.hostName}.options";
            in
            {
              nixpkgs.expr = "import ${myFlake}.inputs.nixpkgs { }";
              formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
              options = {
                nixos.expr = nixosOpts;
                home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions []";
              };
            };
        };
      };
    };
  };

  home.stateVersion = "25.05";
}
