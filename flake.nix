{
  description = "Michal Kononenko's operating system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sphinxcontrib-nixdomain = {
      url = "github:minijackson/sphinxcontrib-nixdomain";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      disko,
      home-manager,
      nixos-wsl,
      sphinxcontrib-nixdomain,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: lib.genAttrs systems (system: f system);

      # Reusable, option-owning modules. This attribute set is the
      # documentation target: sphinxcontrib-nixdomain renders only options
      # declared under the `self` source, so anything documented has to be a
      # module here rather than an inline assignment in a host file.
      #
      # Each module must evaluate without any `_module.args` that a host would
      # normally supply, because the docs build imports them in isolation.
      nixosModules = {
        agenix = ./modules/agenix;
        agent = ./modules/agent;
        baseline = ./modules/baseline.nix;
        desktop = ./modules/desktop;
        server = ./modules/server;
        "users/mkononenko" = ./modules/users/mkononenko.nix;
      };

      # Aggregated form, for hosts that want everything.
      nixosModulesAll = {
        imports = builtins.attrValues nixosModules;
      };

      # Third-party modules our own modules depend on. The docs build imports
      # these so that `modules/agent/opencode.nix` can be evaluated on its own
      # once it exists. The options they declare are filtered back out by
      # sphinxcontrib-nixdomain's "declared in self" default filter.
      nixosModuleDependencies = [
        agenix.nixosModules.default
        disko.nixosModules.default
      ];

      # A home-manager configuration for the user directory `name`, deployed
      # onto the NixOS configuration named `host`.
      #
      # The account name is not passed here: home-manager derives it from
      # `home.username` inside `home/<name>/default.nix`.
      #
      # `osConfig` is passed explicitly rather than relying on the
      # NixOS-embedded home-manager module to inject it, so that a home
      # configuration stays evaluable on its own. This is also what makes the
      # system/user split a directory boundary rather than a judgement call:
      # `modules/` is the NixOS side, `home/` is the home-manager side, and
      # they meet only here.
      homeFor =
        name: host: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            osConfig = self.nixosConfigurations.${host}.config;
            inherit inputs;
          };
          modules = [ ./home/${name} ];
        };
    in
    {
      nixosModules = nixosModules // {
        default = nixosModulesAll;
      };

      nixosConfigurations = {
        # `agenix.nixosModules.default` is imported on every host that imports
        # ./modules, because ./modules contains mkononenko.agenix, which sets
        # `age.*` and therefore cannot be enabled without it. It is inert
        # unless a host declares a secret: `age.enable` defaults to false and
        # the module creates no services.
        artax = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./configurations/artax
            ./modules
            agenix.nixosModules.default
          ];
        };

        tianma1 = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./configurations/tianma1
            ./modules
            agenix.nixosModules.default
            disko.nixosModules.default
          ];
        };

        wsl = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            ./hosts/wsl
            # hosts/wsl imports ./modules, which contains mkononenko.agenix and
            # mkononenko.agent. Inert here, but its option definitions have to
            # type-check.
            agenix.nixosModules.default
            {
              system.stateVersion = "26.05";
              wsl.enable = true;
            }
          ];
        };
      };

      homeManagerConfigurations = {
        "mkononenko@artax" = homeFor "mkononenko" "artax" "x86_64-linux";
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ sphinxcontrib-nixdomain.overlays.default ];
          };

          # JSON of every option documented in this repository, consumed by
          # sphinxcontrib-nixdomain at build time to render `autooption`
          # blocks. Shared by the HTML and LaTeX documentation builds so the
          # two cannot drift apart.
          nixdomainObjects = sphinxcontrib-nixdomain.lib.documentObjects {
            sources = {
              self = self.outPath;
              nixpkgs = nixpkgs.outPath;
            };
            options = {
              # Imported in isolation: the repository's own modules, plus the
              # third-party modules they need. No host, because a host would
              # contribute nixpkgs options that the filter discards anyway.
              options =
                (lib.nixosSystem {
                  inherit system;
                  modules =
                    builtins.attrValues nixosModules
                    ++ nixosModuleDependencies
                    # No host is imported, so there is no release to record.
                    # Nothing is built from this evaluation, so the value is
                    # irrelevant; setting it just keeps the warning out of
                    # the build log.
                    ++ [
                      (
                        { config, ... }:
                        {
                          system.stateVersion = config.system.nixos.release;
                        }
                      )
                    ];
                }).options;
            };
            # `packages` and `library` are deliberately omitted. This
            # repository exports no custom packages and no `lib`, and
            # documenting nixpkgs' would mean documenting all of it. Both
            # become worth passing once there is something of ours to show.
          };
        in
        {
          docs = pkgs.callPackage ./docs/html.nix { inherit nixdomainObjects; };

          latexDocs = pkgs.callPackage ./docs/latex.nix { inherit nixdomainObjects; };
        }
      );

      # `nix flake check` already evaluates and builds every entry in
      # `nixosConfigurations` and `nixosModules`, so those need no check here.
      # Two things it does *not* cover:
      #
      #   - `homeManagerConfigurations`, which it reports as an unknown flake
      #     output and skips entirely;
      #   - undocumented modules, which Sphinx renders as silently absent
      #     rather than as an error.
      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          docs = self.packages.${system}.docs;

          docs-coverage = pkgs.runCommand "docs-coverage" { } ''
            mkdir -p docs/source
            cp -r ${./modules} modules
            cp -r ${./docs/source/modules} docs/source/modules
            chmod -R u+w .
            export HOME=$TMPDIR
            bash ${./scripts/docs-coverage.sh}
            touch $out
          '';

          # Forces evaluation of every home-manager configuration. Wrapped in a
          # runCommand so that the check is a derivation rather than a nested
          # attribute set of them.
          home-manager = pkgs.runCommand "home-manager-eval" { } ''
            touch $out
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                name: config: "echo ${name}: ${config.activationPackage.drvPath}"
              ) self.homeManagerConfigurations
            )}
          '';
        }
      );

      # Convenience wrappers, so the checks above are runnable by hand.
      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          docs-coverage = {
            type = "app";
            program = lib.getExe (
              pkgs.writeShellApplication {
                name = "docs-coverage";
                text = ''
                  exec bash ${./scripts/docs-coverage.sh} "''${1:-.}"
                '';
              }
            );
            meta.description = "Check that every module has a documentation page";
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.deadnix
              pkgs.nixd
              pkgs.statix
              pkgs.treefmt
            ];
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.writeShellScript "format" ''
          exec ${lib.getExe pkgs.nixfmt} $(find . -name '*.nix' -not -path './result/*')
        ''
      );
    };
}
