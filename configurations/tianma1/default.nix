# Tianma 1: headless Hetzner VPS.
#
# Composition only. Everything reusable lives in `modules/`; the facts about
# this machine live in `hosts/tianma1/`.
{
  pkgs,
  ...
}:

{
  imports = [
    ../../hosts/tianma1
    # Populated at install time by nixos-infect. This host's address and
    # interface MAC live here.
    ./networking.nix
  ];

  # The OpenCode agent is intentionally NOT enabled here.
  #
  # mkononenko.agenix refuses to activate without an identity it can decrypt
  # with, and the identity in secrets/identity.age is not yet bound to this
  # host. Enabling it now would give a machine that enables agenix and then
  # cannot decrypt anything it needs.
  #
  # To turn it on, follow secrets/README.md: encrypt the real credentials,
  # install the identity as `agenix -R`, then uncomment these two lines.
  #
  # mkononenko.agenix.enable = true;
  # mkononenko.agent.enable = true;

  mkononenko.server = {
    enable = true;
    zramSwap.enable = true;
    ssh.authorizedKeys = [
      # https://github.com/MichalKononenko2.keys
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOefZFAWHuM2NJoeP2Jyr2CNw+phDH1xrrAruTQ7k4bj michalkononenko@gmail.com"
    ];
  };

  networking.hostName = "tianma-1";
  networking.domain = "";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  users.users.openclaw = {
    isNormalUser = true;
    group = "openclaw";
    home = "/home/openclaw";
    shell = pkgs.bash;
  };
  users.groups.openclaw = { };

  system.stateVersion = "25.11";
}

