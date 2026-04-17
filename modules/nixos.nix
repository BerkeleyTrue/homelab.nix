{
  lib,
  inputs,
  config,
  ...
}: {
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.system = lib.mkOption {
          type = lib.types.str;
        };
        options.modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
        };
        options.specialArgs = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
        };
      }
    );
    default = {};
  };

  config.flake.nixosConfigurations = lib.mapAttrs (hostname: {
    system,
    modules,
    specialArgs,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = modules;
    })
  config.configurations.nixos;
}
