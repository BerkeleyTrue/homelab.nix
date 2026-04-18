{
  lib,
  inputs,
  config,
  ...
}: {
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
        };
      }
    );
    default = {};
  };

  config.flake.nixosConfigurations = lib.mapAttrs (hostname: {modules}:
    inputs.nixpkgs.lib.nixosSystem {
      modules = modules;
    })

  config.configurations.nixos;
}
