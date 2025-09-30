{...}: let 
  host = "0.0.0.0";
  port = 33299;
  user = "audiobookshelf";
  group = "audiobookshelf";
in {
  services.audiobookshelf = {
    enable = true;

    dataDir = "/mnt/storate/audiobookshelf";
    host = host;
    port = port;
    user = user;
    group = group;
    openFirewall = true;
  };

  services.traefik.dynamicConfigOptions.http.services.audiobookshelf = {
    loadBalancer = {
      servers = [{url = "http://${host}:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.audiobookshelf = {
    entrypoints = ["web"];
    service = "audiobookshelf";
    rule = "Host(`audiobookshelf.r3dm.com`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.audiobookshelf-secure = {
    entrypoints = ["secureweb"];
    service = "audiobookshelf";
    rule = "Host(`audiobookshelf.r3dm.com`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };
}
