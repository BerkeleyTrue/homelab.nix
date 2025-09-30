{...}: let 
  traefik_public_url = "r3dm.com";
  host = "0.0.0.0";
  port = 33299;
  user = "audiobookshelf";
  group = "audiobookshelf";
  dataDir = "/mnt/storate/audiobookshelf";
in {
  services.audiobookshelf = {
    enable = true;

    dataDir = dataDir;
    host = host;
    port = port;
    user = user;
    group = group;
    openFirewall = true;
  };

  systemd.services.aduiobookshelf.serviceConfig.StateDirectory = baseNameOf dataDir;
  systemd.services.aduiobookshelf.serviceConfig.WorkingDirectory = dataDir;
  users.users.audiobookshelf.home = dataDir;

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
  ];
}
