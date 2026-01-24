{config, ...}: let
  traefik_public_url = "r3dm.com";
  port = 8123;
  homekit_port = 51827;
  mqtt_port = 1883;
  zigbee2mqtt_port = 9090;
  mDNS = 5353;
in {
  nixpkgs.config.permittedInsecurePackages = [
    "python3.12-ecdsa-0.19.1"
  ];

  networking.firewall.allowedTCPPorts = [
    mqtt_port
    homekit_port # allow homekit protocol devices to connect to ha
  ];
  networking.firewall.allowedUDPPorts = [
    mDNS # allow mDNS for homekit announcements
  ];

  services.home-assistant = {
    enable = true;

    openFirewall = true;

    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "tasmota"
      "openweathermap"
      "homekit_controller"
      "google_translate" # text to speech
      "ecobee"
      "zha" # zigbee home assistant
      "cast" # chrome cast
    ];

    config = {
      # provide sane defaults
      default_config = {};

      homeassistant = {
        name = "roseann";
        unit_system = "us_customary";
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

      frontend = {
        enable = true;
        port = zigbee2mqtt_port;
        host = "127.0.0.1";
      };
    };
  };

  services.traefik.dynamicConfigOptions.http.services.z2m = {
    loadBalancer = {
      servers = [{url = "http://127.0.0.1:${toString zigbee2mqtt_port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.z2m = {
    entrypoints = "web";
    service = "z2m";
    rule = "Host(`z2m.${traefik_public_url}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.z2m-secure = {
    entrypoints = "secureweb";
    service = "z2m";
    rule = "Host(`z2m.${traefik_public_url}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };

  services.esphome = {
    enable = true;
    openFirewall = true;
  };
}
