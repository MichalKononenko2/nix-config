# Baseline for a headless server reachable over SSH.
#
# Everything here is a judgement call that suits a machine with no keyboard and
# no monitor attached. It is deliberately conservative: the defaults harden SSH
# but never remove key-based access, so enabling this module cannot lock the
# owner out of their own machine.
{
  config,
  lib,
  ...
}:

let
  cfg = config.mkononenko.server;
in
{
  options.mkononenko.server = {
    enable = lib.mkEnableOption "the headless server baseline";

    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to run an SSH daemon.

          On by default, because a headless server with no SSH daemon cannot be
          reached at all. Turn it off only if something else provides remote
          access.
        '';
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "ssh-ed25519 AAAAC3Nz... me@example.com" ];
        description = ''
          Public keys granted root access via
          `users.users.root.openssh.authorizedKeys.keys`.

          Empty by default. There is deliberately no default key: this option
          belongs in the host configuration, where the specific machine's
          owner is a fact rather than a reusable default.
        '';
      };

      permitRootLogin = lib.mkOption {
        type = lib.types.enum [
          "yes"
          "without-password"
          "prohibit-password"
          "no"
        ];
        default = "prohibit-password";
        example = "no";
        description = ''
          Value for `services.openssh.permitRootLogin`.

          The default refuses password authentication for root while leaving
          public-key authentication working, so it cannot lock out an owner who
          already has a key in place. Set `"no"` once a non-root administrative
          account exists.
        '';
      };

      passwordAuthentication = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          Value for `services.openssh.passwordAuthentication`.

          Off by default. This is only safe because
          `mkononenko.server.ssh.authorizedKeys` is expected to be non-empty;
          if it is empty, SSH will reject every connection and the machine must
          be recovered out of band.
        '';
      };
    };

    zramSwap.enable = lib.mkEnableOption "compressed swap in RAM via zram";

    tmp.cleanOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to clear `/tmp` on boot.

        Sensible for a machine that is not restarted often and would otherwise
        accumulate temporary files indefinitely.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    zramSwap.enable = cfg.zramSwap.enable;
    boot.tmp.cleanOnBoot = cfg.tmp.cleanOnBoot;

    services.openssh = {
      enable = cfg.ssh.enable;
      settings = {
        PermitRootLogin = cfg.ssh.permitRootLogin;
        PasswordAuthentication = cfg.ssh.passwordAuthentication;
      };
    };

    users.users.root.openssh.authorizedKeys.keys = cfg.ssh.authorizedKeys;
  };
}
