# ─── Additions to your existing flake.nix ────────────────────────────────────
#
# This is not a full flake — it shows only the lines you need to ADD or CHANGE
# in your existing MichalKononenko2/nix-config (OpenClaw branch) flake.nix.
#
# ─────────────────────────────────────────────────────────────────────────────

{
  inputs = {
    # … your existing inputs (nixpkgs, home-manager, etc.) stay as-is …

    # ADD THIS:
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";          # share your nixpkgs pin
      inputs.home-manager.follows = "home-manager"; # share your hm pin
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-openclaw, ... }@inputs:
  {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # … your existing NixOS modules …

        # ADD THIS — brings the home-manager NixOS module in as usual:
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; }; # passes inputs to user.nix

          home-manager.users.openclaw = import ./home/openclaw/user.nix;
        }

        # ADD THIS — wires the nix-openclaw home-manager module into every HM user:
        nix-openclaw.homeManagerModules.openclaw
      ];
    };
  };
}
