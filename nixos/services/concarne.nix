{ lib,
  concarne,
  pkgs,
  ...
}: let
  traefik_public_url = "r3dm.com";
  package = concarne.packages.${pkgs.system}.default;
  port = 9223;
  user = "concarne";
  group = "concarne";
  dataDir = "/mnt/storage/concarne";
in {

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${group} - -"
  ];

  systemd.services.concarne = {
    description = "Concarne - A simple, fast, and secure web server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      DATABASE_URL = "file:" + dataDir + "/concarne.sqlite";
      PORT = toString port;
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

  users.users.concarne = {
    inherit group;
    isSystemUser = true;
    home = dataDir;
  };

  users.groups.concarne = {};

  networking.firewall.allowedTCPPorts = [port];

  services.traefik.dynamicConfigOptions.http.services.concarne = {
    loadBalancer = {
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.concarne = {
    entrypoints = "web";
    service = "concarne";
    rule = "Host(`concarne.${traefik_public_url}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.concarne-secure = {
    entrypoints = "secureweb";
    service = "concarne";
    rule = "Host(`concarne.${traefik_public_url}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };
}
