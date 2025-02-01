{config, ...}: let
  traefik_public_url = "r3dm.com";
  port = 8123;
  mqtt_port = 1883;
in {
  services.home-assistant = {
    enable = true;

    openFirewall = true;

    extraComponents = [
      "esphome"
      "tasmota"
      "openweathermap"
    ];

    config = {
      # provide sane defaults
      default_config = {};

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

      mqtt = {};
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

  sops.secrets.mosquitto_password = {};

  networking.firewall.allowedTCPPorts = [mqtt_port];

  services.mosquitto = {
    enable = true;

    listeners = [
      {
        address = "127.0.0.1";
        port = mqtt_port;
        users.mosquitto = {
          acl = ["readwrite #"];
          passwordFile = config.sops.secrets.mosquitto_password.path;
        };
      }
    ];
  };

  sops.templates."mqtt_password.yml".content = ''
    mqtt_password: "${config.sops.placeholder.mosquitto_password}"
  '';

  sops.templates."mqtt_password.yml".owner = config.users.users.zigbee2mqtt.name;

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      serial.port = "/dev/ttyUSB0";
      availability = true;
      mqtt = {
        user = "mosquitto";
        password = "!${config.sops.templates."mqtt_password.yml".path} mqtt_password";
      };
    };
  };

  services.esphome = {
    enable = true;
    openFirewall = true;
  };
}
