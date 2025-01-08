{
  description = "My homelab flake";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager-parts.url = "github:berkeleytrue/home-manager-parts";
    boulder.url = "github:berkeleytrue/nix-boulder-banner";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.boulder.flakeModule
        inputs.home-manager-parts.flakeModule
        ./home
      ];
      perSystem = {
        config,
        system,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;

          overlays = [
          ];

          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
            ];
          };
        };

        home-uri = ".\#homeConfigurations.homelab";
        activation-package-uri = "${home-uri}.activationPackage";

        nixos-build = pkgs.writeShellScriptBin "nixos-build" ''
          # check if nixos-rebuild is available
          sudo nixos-rebuild switch --flake .
        '';

        nixos-dryrun = pkgs.writeShellScriptBin "nixos-dryrun" ''
          # check if nixos-rebuild is available
          nixos-rebuild dry-run --flake .
        '';

        home-manager-build = pkgs.writeShellScriptBin "home-manager-build" ''
          # check if home-manager is available
          nix build \
            --show-trace \
            --no-link \
            --print-build-logs \
            ${activation-package-uri} &&
            nix flake show . && \
            nix path-info ${activation-package-uri}
        '';

        get-home-manager-path = pkgs.writeShellScriptBin "get-home-manager-path" ''
          nix path-info ${activation-package-uri}.
        '';

        home-manager-switch = pkgs.writeShellScriptBin "home-manager-switch" ''
          eval "$(${get-home-manager-path}/bin/get-home-manager-path)/home-path/bin/home-manager switch --flake ."
        '';
      in {
        formatter = pkgs.alejandra;
        _module.args.pkgs = pkgs;

        boulder.commands = [
          {
            category = "system";
            description = "Switch NixOS";
            exec = nixos-build;
          }
          {
            category = "system";
            description = "Dry run NixOS";
            exec = nixos-dryrun;
          }
          {
            category = "user";
            description = "build Home Manager";
            exec = home-manager-build;
          }
          {
            category = "user";
            description = "switch Home Manager";
            exec = home-manager-switch;
          }
        ];

        devShells.default = pkgs.mkShell {
          inputsFrom = [config.boulder.devShell];
        };
      };
      flake = {
        nixosConfigurations.homelab = inputs.nixpkgs.lib.nixosSystem {
          modules = [./nixos/configuration.nix];
          system = "x86_64-linux";
        };
      };
    };
}
