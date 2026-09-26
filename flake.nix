{
  description = "Michal Kononenko's operating system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    sphinxcontrib-nixdomain = {
      url = "github:minijackson/sphinxcontrib-nixdomain";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-nix = {
      url = "github:dan-online/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self,
    nixpkgs, 
    sphinxcontrib-nixdomain,
    nixos-wsl,
    opencode-nix
  }@inputs: {
    nixosConfigurations = 
      let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ opencode-nix.overlays.default ];
        };
      in
      {
        artax = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./configurations/artax ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            {
              system.stateVersion = "26.05";
              wsl.enable = true;
              networking.resolvconf.enable = false;
            }
          ];
        };
      };

  packages.x86_64-linux =
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ sphinxcontrib-nixdomain.overlays.default ];
      };
    in
    {
      docs = pkgs.callPackage ./docs {
        nixdomainObjects = sphinxcontrib-nixdomain.lib.documentObjects {
          sources = {
            self = self.outPath;
            nixpkgs = nixpkgs.outPath;
          };
          options.options = self.nixosConfigurations.artax.options;
          packages.packages = self.packages.x86_64-linux; 
        };
      };
    };
  };
}

