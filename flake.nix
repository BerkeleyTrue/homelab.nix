{
  description = "My homelab flake";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";

    tiab.url = "github:berkeleytrue/tiab";
    concarne.url = "github:berkeleytrue/concarne";

    # utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager-parts.url = "github:berkeleytrue/home-manager-parts";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.home-manager-parts.flakeModule
        ./home
      ];
      perSystem = {system, ...}: let
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
      in {
        formatter = pkgs.alejandra;
        _module.args.pkgs = pkgs;

        devShells.default = pkgs.mkShell {
          name = "homelab";
          buildInputs = with pkgs; [
            just
          ];
          shellHook = ''
            function menu () {
              echo
              echo -e "\033[1;34m>==> ️  '$name'\n\033[0m"
              ${pkgs.just}/bin/just --list
              echo
              echo "(Run 'just --list' to display this menu again)"
              echo
            }

            menu
          '';
        };
      };
      flake = {
        nixosConfigurations.homelab = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            ./nixos/configuration.nix
            inputs.sops-nix.nixosModules.sops
          ];
          specialArgs = {
            inherit (self) outPath;
            inherit (inputs) tiab concarne;
          };
        };
      };
    };
}
