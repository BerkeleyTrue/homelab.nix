{...}: let
  traefik_public_url = "r3dm.com";
  port = 8123;
in {
  services.home-assistant = {
    enable = true;

    openFirewall = true;

    config = {
      homeassistant = {
        name = "roseann";
        unit_system = "imperial";
        temperature_unit = "F";
        time_zone = "America/Los_Angeles";
      };
      http = {
        server_port = port;
        trusted_proxies = "127.0.0.1";
        use_x_forwarded_for = true;
      };
    };
  };

  services.traefik.dynamicConfigOptions.http.services.home-assistant = {
    loadBalancer = {
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.home-assistant = {
    entrypoints = "web";
    service = "home-assistant";
    rule = "Host(`home-assistant.${traefik_public_url}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.home-assistant-secure = {
    entrypoints = "secureweb";
    service = "home-assistant";
    rule = "Host(`home-assistant.${traefik_public_url}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };
}
