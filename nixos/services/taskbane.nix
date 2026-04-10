{ lib,
  tiab,
  pkgs,
  ...
}: let
  name = "taskbane";
  traefik_public_url = "r3dm.com";
  package = tiab.packages.${pkgs.system}.default;
  port = 7753;
  user = name;
  group = name;
  dataDir = "/mnt/storage/${name}";
  origin = "${name}.${traefik_public_url}";
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${group} - -"
  ];

  systemd.services.${name} = {
    description = "Taskbane: A taskwarrior Web Ui";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      DB_URL = "file:" + dataDir + "/${name}.sqlite";
      PORT = toString port;
      ORIGIN = origin;
      RP_ID = origin;
      RP_NAME = name;
    };

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      StateDirectory = baseNameOf dataDir;
      WorkingDirectory = dataDir;
      ExecStart = "${lib.getExe package}";
      Restart = "on-failure";
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
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.${name} = {
    entrypoints = "web";
    service = name;
    rule = "Host(`${origin}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers."${name}-secure" = {
    entrypoints = "secureweb";
    service = name;
    rule = "Host(`${origin}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };
}
