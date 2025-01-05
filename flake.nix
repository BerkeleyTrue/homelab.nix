{
  description = "My homelab flake";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager-parts.url = "github:berkeleytrue/home-manager-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.home-manager-parts.flakeModule
      ];
      perSystem = {
        system,
        ...
      }:
        let
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
	  nixosConfiguration = {
	    homelab = nixpkgs.lib.nixosSystem {
	    	specialArgs = { inherity system; };

		modules = [ ./nixos/configuration.nix ];
	    };
          };
        };
}
