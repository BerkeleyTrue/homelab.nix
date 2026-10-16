{
  flake.modules.nixos.forgejo = {config, ...}: let
    name = "forgejo";
    user = name;
    group = name;
    public_url = config.traefik.public_url;
    domain = "${name}.${public_url}";
    host = "0.0.0.0";
    port = 3330;
    dataDir = "/mnt/storage/${name}";
    # already the default state dir
    # stateDir = "/var/lib/${name}";
  in {
    services.forgejo = {
      enable = true;
      stateDir = dataDir;
      database.type = "sqlite3";
      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = host;
          HTTP_PORT = port;
          # git over ssh goes through the system openssh server
          SSH_DOMAIN = domain;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    networking.firewall.allowedTCPPorts = [port];

    services.traefik.dynamicConfigOptions.http.services.forgejo = {
      loadBalancer = {
        servers = [{url = "http://${host}:${toString port}";}];
        passHostHeader = true;
      };
    };

    services.traefik.dynamicConfigOptions.http.routers.forgejo = {
      entrypoints = "web";
      service = "forgejo";
      rule = "Host(`${domain}`)";

      middlewares = ["ssl-redirect" "ssl-header"];
    };

    services.traefik.dynamicConfigOptions.http.routers.forgejo-secure = {
      entrypoints = "secureweb";
      service = "forgejo";
      rule = "Host(`${domain}`)";

      middlewares = ["default-headers"];
      tls.certResolver = "letsencrypt";
    };

    # Ensure the data directory exists
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} - -"
      "d ${dataDir}/custom 0755 ${user} ${group} - -"
      "d ${dataDir}/custom/conf 0755 ${user} ${group} - -"
    ];
  };
}
