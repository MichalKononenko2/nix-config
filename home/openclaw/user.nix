{ pkgs, inputs, lib, ... }:

{
  home.username = "openclaw";
  home.homeDirectory = lib.mkForce "/home/openclaw";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  programs.bash.enable = true;

  # ─── OpenClaw gateway (AI assistant, runs as systemd user service) ────────────
  #
  # Secrets you must create on the VPS before running nixos-rebuild:
  #
  #   mkdir -p ~/.secrets
  #   echo "YOUR_TELEGRAM_BOT_TOKEN" > ~/.secrets/telegram-bot-token
  #   chmod 600 ~/.secrets/telegram-bot-token
  #
  # Set your Anthropic key as an environment variable or add it to:
  #   ~/.config/environment.d/openclaw.conf  →  ANTHROPIC_API_KEY=sk-ant-…
  #
  programs.openclaw = {
    enable = true;

    config = {
      # Gateway runs locally (loopback only — safe default for a VPS).
      gateway = {
        mode = "local";
        auth.token = "REPLACE_WITH_RANDOM_UUID"; # or set OPENCLAW_GATEWAY_TOKEN env var
      };

      # Telegram is the primary channel.
      # Get a bot token from @BotFather, your chat ID from @userinfobot.
      channels.telegram = {
        tokenFile = "/home/openclaw/.secrets/telegram-bot-token";
        allowFrom = [ 0 ]; # REPLACE with your Telegram user ID (integer)
      };
    };

    workspace.bootstrapFiles = {
      agents = ./AGENTS.md;
      soul = ./SOUL.md;
      tools = ./TOOLS.md;
      identity = ./IDENTITY.md;
      user = ./USER.md;
    };
  };

  # ─── GitHub review tooling ───────────────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  home.packages = with pkgs; [
    # gh-dash — TUI dashboard for PRs/issues (run: gh dash)
    gh-dash
  ];
}
