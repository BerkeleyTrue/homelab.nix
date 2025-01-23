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
        unit_system = "us_customary";
        temperature_unit = "F";
        time_zone = "America/Los_Angeles";
      };
      http = {
        server_port = port;
      };
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.home-assistant = {
    entrypoints = "web";
    rule = "Host(`home-assistant.${traefik_public_url}`)";
    service = "home-assistant";
    middlewares = ["default-headers"];
  };

  services.traefik.dynamicConfigOptions.http.services.home-assistant = {
    loadBalancer = {
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };
}
