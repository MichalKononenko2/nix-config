{ pkgs, ... } @ args:
{
  imports = [
    ../../hosts/tianma1
    ./networking.nix # generated at runtime by nixos-infect
  ];

  users.users.openclaw = {
    isNormalUser = true;
    group = "openclaw";
    home = "/home/openclaw";
    shell = pkgs.bash;
  };
  users.groups.openclaw = {};

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "tianma-1";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOefZFAWHuM2NJoeP2Jyr2CNw+phDH1xrrAruTQ7k4bj michalkononenko@gmail.com"
  ] ++ (args.extraPublicKeys or []);
  system.stateVersion = "25.11";
}

