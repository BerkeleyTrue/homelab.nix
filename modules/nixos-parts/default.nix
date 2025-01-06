{
  config,
  lib,
  inputs,
  withSystem,
  ...
}: let
  inherit (lib) mkIf mkMerge mkOption mkEnableOption types optionals;
  cfg = config.nixos-parts;
  shared = cfg.shared;
  hosts = cfg.hosts;
in {
  options.nixos-parts = {
    enable = mkEnableOption {
      default = false;
      description = "Enable nixos-parts flake";
    };

    defaults = {
      hostPlatform = mkOption {
        type = types.enum ["aarch64-linux" "x86_64-linux"];
        description = "Default host platform.";
        default = "x86_64-linux";
      };

      stateVersion = mkOption {
        type = types.str;
        description = "Default state version";
      };
    };

    shared = {
      modules = mkOption {
        type = types.listOf types.unspecified;
        description = "Shared modules for all hosts";
        default = [];
      };

      extraSpecialArgs = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          option can be used to pass additional arguments to all modules on all hosts.
        '';
      };
    };

    hosts = mkOption {
      type = types.attrsOf (types.submodule ({
        name, # key of attr
        config,
        ...
      }: let
        hostCfg = config;
        inherit
          (withSystem hostCfg.hostPlatform ({inputs', ...}: {inherit inputs';}))
          inputs'
          ;
      in {
        options = {
          enable = mkEnableOption {
            default = false;
            description = "Enable hosts ${name}'s flake";
          };

          hostname = mkOption {
            type = types.str;
            description = "Hostname for ${name}, defaults to config key";
            default = name;
          };

          hostPlatform = mkOption {
            type = types.enum ["aarch64-linux" "x86_64-linux"];
            description = "Host platform, defaults to defaults.hostPlatform";
            default = cfg.defaults.hostPlatform;
          };

          username = mkOption {
            type = types.str;
            description = "Username for host ${name}";
          };

          installer = mkOption {
            type = types.unspecified;
            description = "Installer for hosts ${name}";
          };

          modules = mkOption {
            type = types.listOf types.unspecified;
            default = [];
            description = "Modules for hosts ${name} (in addition to the default modules and installer)";
          };

          specialArgs = mkOption {
            type = types.attrs;
            default = {};
            description = ''
              option can be used to pass additional arguments to all modules on this host.
            '';
          };

          stateVersion = mkOption {
            type = types.str;
            description = "State version for hosts ${name}, defaults to defaults.stateVersion";
            default = cfg.defaults.stateVersion;
          };

          nixos = mkOption {
            type = types.unspecified;
            readOnly = true;
            description = "The derived NixOS configuration for hosts ${name}";
          };
        };

        config.nixos = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs';
            inherit (shared) extraSpecialArgs;
            inherit (config) specialArgs stateVersion username hostname hostPlatform;
          };

          modules =
            [(_: {nixpkgs.hostPlatform = config.hostPlatform;})]
            ++ shared.modules
            ++ (optionals (config.installer != null) [config.installer])
            # additional modules
            ++ config.modules;
        };
      }));
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      flake.nixosConfigurations = builtins.mapAttrs (_: value: value.nixos) hosts;
    })
  ];
}
