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
  };

  outputs =
    { nixpkgs, home-manager, disko, ... }@inputs:
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

        sphinxcontrib-nixdomain = pkgs.python3Packages.buildPythonPackage rec {
          pname = "sphinxcontrib-nixdomain";
          version = "0.1.4";
          pyproject = true;
          build-system = [ pkgs.python3Packages.hatchling ];
          propagatedBuildInputs = [ 
            pkgs.python3Packages.sphinx 
            pkgs.python3Packages.pydantic
          ];
          src = pkgs.fetchFromGitHub {
            owner = "minijackson";
            repo = "sphinxcontrib-nixdomain";
            rev = "v0.1.4";
            hash = "sha256-dyXEyVTi2bfX+LlIpnx39DlEVk5mvbJ9cBY9O+MzJAo=";
          };
        };

        sphinxEnv = pkgs.python3.withPackages (
          ps: [
            ps.sphinx
            sphinxcontrib-nixdomain
          ]
        );
      in {
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
            ];
          };
        };

        devShells.${system}.docs = pkgs.mkShell {
          packages = [ sphinxEnv pkgs.gnumake ];
        };
      };
}

