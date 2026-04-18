{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
        ];
      };
    };
  };

  flake.modules.nixos.nix = {
    lib,
    pkgs,
    ...
  }: {
    # garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nix.settings.auto-optimise-store = true;
    # avoid unwanted garbage collection
    nix.settings.keep-outputs = true;
    nix.settings.keep-derivations = true;
    nix.settings.warn-dirty = false;
  };
}
