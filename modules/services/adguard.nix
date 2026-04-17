{
  flake.modules.nixos.adguard = {config, ...}: let
    public_url = config.traefik.public_url;
  in {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
    };

    networking.firewall.allowedUDPPorts = [53];

    services.traefik.dynamicConfigOptions.http.services.adguard = {
      loadBalancer = {
        servers = [{url = "http://${config.services.adguardhome.host}:${toString config.services.adguardhome.port}";}];
        passHostHeader = true;
      };
    };

    services.traefik.dynamicConfigOptions.http.routers.adguard = {
      entrypoints = "web";
      service = "adguard";
      rule = "Host(`adguard.${public_url}`)";

      middlewares = ["ssl-redirect" "ssl-header"];
    };

    services.traefik.dynamicConfigOptions.http.routers.adguard-secure = {
      entrypoints = "secureweb";
      service = "adguard";
      rule = "Host(`adguard.${public_url}`)";

      middlewares = ["default-headers"];
      tls.certResolver = "letsencrypt";
    };
  };
}
