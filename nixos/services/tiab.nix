{
  lib,
  tiab,
  pkgs,
  ...
}: let
  traefik_public_url = "r3dm.com";
  package = tiab.packages.${pkgs.system}.default;
  port = 9743;
  user = "tiab";
  group = "tiab";
  dataDir = "/mnt/storage/tiab";
in {
  systemd.services.tiab = {
    description = "Trapped In A Box - A personal Inventory System";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      DATABASE_URL = "file:" + dataDir + "/tiab.sqlite";
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

  users.users.tiab = {
    inherit group;
    isSystemUser = true;
    home = dataDir;
  };

  users.groups.tiab = {};

  networking.firewall.allowedTCPPorts = [port];

  services.traefik.dynamicConfigOptions.http.services.tiab = {
    loadBalancer = {
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.tiab = {
    entrypoints = "web";
    service = "tiab";
    rule = "Host(`tiab.${traefik_public_url}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.tiab-secure = {
    entrypoints = "secureweb";
    service = "tiab";
    rule = "Host(`tiab.${traefik_public_url}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };
}
