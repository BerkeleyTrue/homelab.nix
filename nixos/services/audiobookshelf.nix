{pkgs, ...}: let
  traefik_public_url = "r3dm.com";
  host = "0.0.0.0";
  port = 33299;
  user = "audiobookshelf";
  group = "audiobookshelf";
  dataDir = "/mnt/storage/audiobookshelf";
in {
  systemd.services.audiobookshelf = {
    description = "Audiobookshelf, a self-hosted audiobook server";

    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";

      User = user;
      Group = group;

      StateDirectory = baseNameOf dataDir;
      WorkingDirectory = dataDir;

      ExecStart = "${pkgs.audiobookshelf}/bin/audiobookshelf --host ${host} --port ${toString port}";

      Restart = "on-failure";
    };
  };

  users.users.audiobookshelf = {
    isSystemUser = true;
    group = group;
    home = dataDir;
  };

  users.groups.audiobookshelf = {};

  networking.firewall.allowedTCPPorts = [port];

  services.traefik.dynamicConfigOptions.http.services.audiobookshelf = {
    loadBalancer = {
      servers = [{url = "http://${host}:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.audiobookshelf = {
    entrypoints = ["web"];
    service = "audiobookshelf";
    rule = "Host(`audiobookshelf.${traefik_public_url}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.audiobookshelf-secure = {
    entrypoints = ["secureweb"];
    service = "audiobookshelf";
    rule = "Host(`audiobookshelf.${traefik_public_url}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };

  # Ensure the data directory exists
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${group} -"
    "d ${dataDir}/library 0755 ${user} ${group} -"
  ];
}
