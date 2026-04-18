{
  flake.modules.nixos.atticd = {
    config,
    lib,
    ...
  }: let
    public_url = config.traefik.public_url;
    host = "0.0.0.0";
    port = 2005;
    name = "atticd";
    user = name;
    group = name;
    dataDir = "/mnt/storage/${name}";
  in {
    sops.secrets.atticd_secret = {};

    sops.templates."${name}.env".content = ''
      ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder.atticd_secret}
    '';

    services.atticd = {
      enable = true;
      environmentFile = config.sops.templates."${name}.env".path;

      inherit user group;

      settings = {
        listen = "${host}:${toString port}";
        jwt = {};
        database.url = "sqlite://${dataDir}/server.db?mode=rwc";
        storage = {
          type = "local";
          path = dataDir;
        };
        # Data chunking
        #
        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };

    users.users.${user} = {
      inherit group;
      isSystemUser = true;
      home = dataDir;
    };

    users.groups.${group} = {};

    networking.firewall.allowedTCPPorts = [port];

    services.traefik.dynamicConfigOptions.http.services.${name} = {
      loadBalancer = {
        servers = [{url = "http://${host}:${toString port}";}];
        passHostHeader = true;
      };
    };

    services.traefik.dynamicConfigOptions.http.routers.${name} = {
      entrypoints = ["web"];
      service = "${name}";
      rule = "Host(`${name}.${public_url}`)";

      middlewares = ["ssl-redirect" "ssl-header"];
    };

    services.traefik.dynamicConfigOptions.http.routers."${name}-secure" = {
      entrypoints = ["secureweb"];
      service = "${name}";
      rule = "Host(`${name}.${public_url}`)";

      middlewares = ["default-headers"];
      tls.certResolver = "letsencrypt";
    };

    # don't need this
    services.atticd.serviceConfig.StateDirectory = lib.mkForce null;
    services.atticd.serviceConfig.DynamicUser = lib.mkForce false;

    # Ensure the data directory exists
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} - -"
    ];
  };
}
