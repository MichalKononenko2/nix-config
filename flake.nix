{
  description = "Michal Kononenko's operating system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sphinxcontrib-nixdomain = {
      url = "github:minijackson/sphinxcontrib-nixdomain";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/2511.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self,
    nixpkgs, 
    home-manager, 
    disko, 
    sphinxcontrib-nixdomain,
    nixos-wsl
  }@inputs: {
    nixosConfigurations = {
      artax = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configurations/artax
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mkononenko = ./home/mkononenko/user.nix;
          }
        ];
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

