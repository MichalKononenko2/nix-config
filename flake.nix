{
  description = "Michal Kononenko's operating system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { 
    self,
    nixpkgs, 
    home-manager, 
    disko, 
    nix-openclaw, 
    sphinxcontrib-nixdomain,
    ...
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

      tianma1 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./configurations/tianma1
          home-manager.nixosModules.home-manager
          { nixpkgs.overlays = [ nix-openclaw.overlays.default ]; }
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [
              nix-openclaw.homeManagerModules.openclaw
            ];
            home-manager.users.openclaw = ./home/openclaw/user.nix;
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
          packages.packages = {
            inherit (self.packages.x86_64-linux) docs;
          };
        };
      };
    };

  devShells.x86_64-linux.default = nixpkgs.mkShell {
    packages = with nixpkgs; [
      python3.pkgs.sphinx
      python3.pkgs.myst-parser
      python3.pkgs.sphinx-design
      python3.pkgs.sphinxcontrib-nixdomain
    ];
  };
  };
}

