{
  lib,
  taskbane,
  pkgs,
  config,
  ...
}: let
  name = "taskbane";
  traefik_public_url = "r3dm.com";
  package = taskbane.packages.${pkgs.system}.default;
  port = 7753;
  user = name;
  group = name;
  dataDir = "/mnt/storage/${name}";
  rp_id = "${name}.${traefik_public_url}";
  origin = "https://${rp_id}";
  tasksync-port = config.services.taskchampion-sync-server.port;
  tasksync-host = config.services.taskchampion-sync-server.host;
  task_url = "http://${tasksync-host}:${toString tasksync-port}";
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${group} - -"
  ];

  sops.secrets.taskbane_client_id = {};
  sops.secrets.taskbane_secret = {};

  sops.templates."taskbane.env".content = ''
    TASK_CLIENT_ID=${config.sops.placeholder.taskbane_client_id}
    TASK_SECRET=${config.sops.placeholder.taskbane_secret}
  '';

  systemd.services.${name} = {
    description = "Taskbane: A taskwarrior Web Ui";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      DB_URL = "file:" + dataDir + "/${name}.sqlite";
      PORT = toString port;
      ORIGIN = origin;
      RP_ID = rp_id;
      RP_NAME = name;
      TASK_URL = task_url;
    };

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      StateDirectory = baseNameOf dataDir;
      WorkingDirectory = dataDir;
      ExecStart = "${lib.getExe package}";
      Restart = "on-failure";
      EnvironmentFile = config.sops.templates."taskbane.env".path;
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
