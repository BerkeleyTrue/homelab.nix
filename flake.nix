{
  description = "My homelab flake";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";

    tiab.url = "github:berkeleytrue/tiab";
    tiab.inputs.nixpkgs.follows = "nixpkgs";

    concarne.url = "github:berkeleytrue/concarne";
    concarne.inputs.nixpkgs.follows = "nixpkgs";

    taskbane.url = "github:berkeleytrue/taskbane";
    taskbane.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        (inputs.import-tree ./modules)
      ];
    };
}
