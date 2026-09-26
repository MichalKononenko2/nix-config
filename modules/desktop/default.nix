# Desktop environment (XMonad + XFCE) and peripherals.
#
# This module declares options under `mkononenko.desktop` and switches on the
# graphical stack that runs on artax. Other hosts that happen to be laptops in
# the future can reuse it without copying configuration.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mkononenko.desktop;
in
{
  options.mkononenko.desktop = {
    enable = lib.mkEnableOption "the desktop environment and GUI applications";

    hostname = lib.mkOption {
      type = lib.types.str;
      example = "artax";
      description = ''
        Hostname used by the Bluetooth controller. The Bluetooth name follows
        the machine name.
      '';
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/New_York";
      example = "Europe/Paris";
      description = ''
        Time zone to set via `time.timeZone`.
      '';
    };

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = ''
        Default system locale.
      '';
    };

    extraLocaleSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
      description = ''
        Extra locale settings passed to `i18n.extraLocaleSettings`.
      '';
    };

    ntfs.enable = lib.mkEnableOption "NTFS filesystem support in the kernel";
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = lib.mkIf cfg.ntfs.enable [ "ntfs" ];

    networking.hostName = cfg.hostname;
    networking.networkmanager.enable = true;

    time.timeZone = cfg.timeZone;

    i18n = {
      defaultLocale = cfg.defaultLocale;
      extraLocaleSettings = cfg.extraLocaleSettings;
    };

    # Configure the X Server
    services.xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = haskellPackages: [
            haskellPackages.xmonad-contrib
            haskellPackages.xmonad-extras
            haskellPackages.xmonad
          ];
          config = ''
            ${builtins.readFile ./xmonad.hs}
            myWallpaper = "${./wallpaper.png}"
          '';
        };
      };
    };
    services.displayManager.defaultSession = "xfce+xmonad";

    # Enable Bluetooth
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      powerOnBoot = true;
      settings = {
        General = {
          Name = cfg.hostname;
          ControllerMode = "dual";
          FastConnectable = "true";
        };
      };
    };

    services.blueman.enable = true;
    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.dbus.packages = [ pkgs.bluez ];

    services.transmission = {
      enable = true;
      package = pkgs.transmission_4;
    };

    environment.variables.EDITOR = "vim";
  };
}
