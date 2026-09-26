# Settings that apply to every host.
#
# This is a *module* in the strict sense: it declares options under
# `mkononenko.nix` rather than assigning Nixpkgs options directly. That
# distinction is what makes the configuration documentable -- see
# docs/source/modules/baseline.md.
#
# Because the documentation build evaluates this module on its own, it must
# not depend on `_module.args` supplied by a host (no `inputs`, no `osConfig`).
{
  config,
  lib,
  ...
}:

let
  cfg = config.mkononenko.nix;
in
{
  options.mkononenko.nix = {
    experimentalFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "nix-command"
        "flakes"
      ];
      example = [
        "nix-command"
        "flakes"
        "kustom-evaluator"
      ];
      description = ''
        Experimental Nix features to enable.

        Forwarded verbatim to `nix.settings.experimental-features`. The Nix
        manual lists the available values and their stability guarantees.
      '';
    };

    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to permit packages whose licences are not considered free by
        Nixpkgs.

        Forwarded to `nixpkgs.config.allowUnfree`. Hosts that install
        proprietary desktop software -- Brave, VS Code, Zoom, Spotify, Dropbox
        -- need this set.
      '';
    };

    cachix.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to add the binary cache named by `mkononenko.nix.cachix.name`
        to the list of substituters.
      '';
    };

    cachix.name = lib.mkOption {
      type = lib.types.str;
      default = "mkononenko-nix-config";
      example = "mkononenko-nix-config";
      description = ''
        Name of the Cachix binary cache to pull prebuilt store paths from.

        Registering a substituter only makes Nix willing to *ask* the cache.
        The cache's public key must also be trusted, which `cachix use
        <name>` writes into `/etc/nix/nix.conf` directly and so cannot be
        expressed here.
      '';
    };
  };

  config = {
    nix.settings.experimental-features = cfg.experimentalFeatures;

    nixpkgs.config.allowUnfree = cfg.allowUnfree;

    # `mkAfter` rather than assignment, so that the Nixpkgs default of
    # `https://cache.nixos.org` survives.
    nix.settings.substituters = lib.mkIf cfg.cachix.enable (
      lib.mkAfter [ "https://${cfg.cachix.name}.cachix.org" ]
    );
  };
}
