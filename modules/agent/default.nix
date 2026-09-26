# A headless OpenCode agent.
#
# The security properties this module is built around, in order:
#
#   1. No privilege. The `agent` account is declared without a single
#      supplementary group: no `wheel`, no `docker`, no `networkmanager`. There
#      is deliberately no option to add groups, because the only thing this
#      account needs to do is run OpenCode.
#   2. No public surface. OpenCode binds to loopback and is reached through
#      `tailscale serve`, so the tailnet is the authentication boundary.
#   3. A second lock on the same door. `OPENCODE_SERVER_PASSWORD` comes from the
#      age secret, so even something running on the host, or a `tailscale serve`
#      forwarding more widely than intended, still has to authenticate.
#   4. Nothing to steal. Provider credentials are decrypted into `/run/agenix`
#      and converted to an EnvironmentFile there, so they never appear in the
#      Nix store, in the account's home directory, or in this repository.
#
# What this module deliberately does NOT do is set `MemoryDenyWriteExecute` or a
# `SystemCallFilter`. OpenCode is a Bun program and Bun JIT-compiles at runtime,
# which needs writable-executable memory. Either option produces a unit that
# starts cleanly and then dies on the first request, which is a far more
# expensive failure than a slightly wider syscall surface.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mkononenko.agent;
  agenixCfg = config.mkononenko.agenix;

  # Where agenix leaves the decrypted, Nix-format secret.
  decryptedSecret = "${agenixCfg.secretsDir}/${cfg.secrets.name}";

  # opencode.json, generated rather than left to an unmanaged file in the
  # agent's home. An unmanaged ~/.config/opencode/opencode.json would be
  # invisible to review and impossible to reproduce on a rebuild.
  opencodeConfig = pkgs.writeText "opencode.json" (
    builtins.toJSON (
      {
        "$schema" = "https://opencode.ai/config.json";
        # The service account must not be phoning home to update itself.
        autoupdate = false;
        # Sessions stay on the box.
        share = "disabled";
      }
      // cfg.opencode.config
    )
  );

  # agenix decrypts a Nix attribute set; a process environment is a flat map of
  # strings. This is the bridge, and it has to run on the host because the
  # contents are encrypted: nothing here can read them at build time.
  #
  # The output is a *shell* file, sourced by runAgent below, not a systemd
  # EnvironmentFile. systemd's parser requires values to be quoted in its own
  # dialect, and a generated password can contain spaces, quotes and
  # backslashes. `jq @sh` quotes for the shell instead, and `source` has no
  # surprises.
  renderedEnvironment = "${agenixCfg.secretsDir}/${cfg.secrets.name}.env";

  renderEnvironment = pkgs.writeShellScript "render-agent-environment" ''
    set -euo pipefail
    umask 077
    ${lib.getExe' pkgs.nix "nix"} eval --file ${decryptedSecret} --json \
      | ${lib.getExe' pkgs.jq "jq"} --raw-output 'to_entries[] | "\(.key)=\(.value | @sh)"' \
      > ${renderedEnvironment}
  '';

  # Sourcing a file of exports requires a shell, so opencode is exec'd from one
  # rather than being the unit's direct ExecStart.
  runAgent = pkgs.writeShellScript "run-opencode" ''
    set -euo pipefail
    set -a
    . ${renderedEnvironment}
    set +a
    exec ${lib.getExe' pkgs.opencode "opencode"} \
      serve \
      --pure \
      --hostname 127.0.0.1 \
      --port ${toString cfg.opencode.port} \
      "$@"
  '';
in
{
  options.mkononenko.agent = {
    enable = lib.mkEnableOption "the headless OpenCode agent";

    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "agent";
        example = "agent";
        description = ''
          Account the service runs as.

          The name is configurable, but nothing else about the account is:
          it has no supplementary groups, so changing the name cannot
          accidentally grant it privilege.
        '';
      };

      home = lib.mkOption {
        type = lib.types.str;
        default = "/home/agent";
        description = "Home directory for the agent account.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = "OpenCode agent";
        description = "GECOS description for the agent account.";
      };

      shell = lib.mkOption {
        type = lib.types.package;
        default = pkgs.bash;
        description = "Login shell for the agent account.";
      };
    };

    opencode = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 4096;
        example = 4096;
        description = ''
          Loopback port the OpenCode server listens on.

          The hostname is hard-coded to `127.0.0.1` and is not an option.
          Binding this to a routable address would put an authenticated but
          internet-reachable agent on the network, which is exactly the mistake
          this module exists to prevent.
        '';
      };

      config = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        example = lib.literalExpression ''
          {
            model = "anthropic/claude-sonnet-4-5";
            permission = { edit = "ask"; bash = "ask"; };
          }
        '';
        description = ''
          Contents of the agent's `opencode.json`, as a Nix attribute set,
          merged over the defaults.

          Written into the state directory at start-up. Because it is a Nix
          value it is reviewable and reproducible; because the account is not a
          home-manager user, a dotfile in its home would be neither.
        '';
      };
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opencode";
      example = "/var/lib/opencode";
      description = ''
        Writable state directory: config, session database and logs.

        Also used as the service's `HOME`, so OpenCode's XDG lookups for
        `~/.config` and `~/.local/share` land inside a directory systemd
        creates and owns, instead of inside a home directory nothing else in
        this configuration manages.
      '';
    };

    tailscale = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Join the tailnet. This is both what makes the agent reachable and
          what keeps it off the public internet.
        '';
      };

      serveCommand = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "tailscale serve --bg ${toString cfg.opencode.port}";
        example = "tailscale serve --bg ${toString cfg.opencode.port}";
        description = ''
          The `tailscale serve` invocation needed to reach the agent, recorded
          in documentation only.

          Not applied by this module: a persistent `tailscale serve` is state on
          the node, not a NixOS setting, and declaring it in the configuration
          tends to fight with `tailscale serve reset` and with the ACLs that
          actually decide who may connect.
        '';
      };
    };

    secrets = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "agent";
        example = "agent";
        description = ''
          Base name of the age secret holding provider credentials and the
          server password, without the `.nix`/`.age` extension.

          The decrypted file must be an attribute set of strings, one per
          environment variable. See secrets/README.md.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.mkononenko.agenix.enable;
        message = ''
          mkononenko.agent requires mkononenko.agenix. The agent needs provider
          credentials, and there is no supported way to pass them as ordinary
          NixOS options without putting them in the Nix store where every build
          can read them.
        '';
      }
    ];

    users.users.${cfg.user.name} = {
      isNormalUser = true;
      description = cfg.user.description;
      home = cfg.user.home;
      createHome = true;
      shell = cfg.user.shell;
      # Intentionally no extraGroups. See the note at the top of this file.
    };

    services.tailscale = lib.mkIf cfg.tailscale.enable {
      enable = true;
      useRoutingFeatures = "client";
    };

    # The encrypted secret. agenix decrypts it during activation, into
    # /run/agenix, owned by the agent and unreadable by anyone else.
    age.secrets.${cfg.secrets.name} = {
      file = ../../secrets/${cfg.secrets.name}.age;
      owner = cfg.user.name;
      group = cfg.user.name;
      mode = "0400";
      # A real file in /run/agenix, not a symlink into the Nix store, which
      # every user on the machine can traverse.
      symlink = false;
    };

    # Flatten the decrypted Nix attrset into a sourceable environment file.
    systemd.services.opencode-secrets = {
      description = "Render agent credentials into a sourceable environment file";
      before = [ "opencode.service" ];
      wantedBy = [ "opencode.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${renderEnvironment}/bin/render-agent-environment";
      };
    };

    # Seed the generated config into the state directory.
    systemd.services.opencode-config = {
      description = "Install the generated opencode.json";
      before = [ "opencode.service" ];
      wantedBy = [ "opencode.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.escapeShellArgs [
          (lib.getExe' pkgs.coreutils "install")
          "-D"
          "-m0644"
          "${opencodeConfig}"
          "${cfg.stateDir}/.config/opencode/opencode.json"
        ];
      };
    };

    systemd.services.opencode = {
      description = "OpenCode agent";
      documentation = [ "https://opencode.ai/docs/server/" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user.name;
        Group = cfg.user.name;
        WorkingDirectory = cfg.stateDir;

        # HOME inside the state directory, so XDG config and data lookups stay
        # inside a directory systemd owns and the service may write to.
        Environment = [
          "HOME=${cfg.stateDir}"
          "XDG_CACHE_HOME=${cfg.stateDir}/.cache"
          "XDG_DATA_HOME=${cfg.stateDir}/.local/share"
          "XDG_CONFIG_HOME=${cfg.stateDir}/.config"
          "OPENCODE_DISABLE_AUTOUPDATE=1"
        ];

        # Credentials are sourced from ${renderedEnvironment} by the wrapper
        # rather than declared as an EnvironmentFile, so they are not part of
        # the unit's declared environment and do not show up in
        # `systemctl show`.
        ExecStart = "${runAgent}/bin/run-opencode";

        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "opencode";
        ReadWritePaths = [ cfg.stateDir ];

        # Hardening. No MemoryDenyWriteExecute and no SystemCallFilter, both
        # because Bun needs writable-executable memory. See the file header.
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ ];
        AmbientCapabilities = [ ];
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RemoveIPC = true;
        # Loopback and the tailnet. AF_UNIX is required for the
        # EnvironmentFile and for Bun's own IPC.
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        SystemCallArchitectures = "native";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user.name} ${cfg.user.name} -"
    ];
  };
}
