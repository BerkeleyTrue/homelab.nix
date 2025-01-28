{
  lib,
  pkgs,
  ...
}: let
  traefik_public_url = "r3dm.com";
  package = pkgs.lubelogger;
  port = 9743;
  user = "lubelogger";
  group = "lubelogger";
  dataDir = "/mnt/storage/lubelogger";
in {
  systemd.services.lubelogger = {
    description = "Lubelogger, a self-hosted, open-source, web-based vehicle maintenance and fuel milage tracker";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      DOTNET_CONTENTROOT = dataDir;
      Kestrel__Endpoints__Http__Url = "http://0.0.0.0:${toString port}";
    };

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      StateDirectory = baseNameOf dataDir;
      WorkingDirectory = dataDir;
      ExecStartPre = pkgs.writeShellScript "lubelogger-prestart" ''
        cd $STATE_DIRECTORY
        if [ ! -e .nixos-lubelogger-contentroot-copied ]; then
          cp -r ${package}/lib/lubelogger/* .
          chmod -R 744 .
          touch .nixos-lubelogger-contentroot-copied
        fi
      '';
      ExecStart = "${lib.getExe package}";
      Restart = "on-failure";
    };
  };


  users.users.lubelogger = {
    inherit group;
    isSystemUser = true;
    home = dataDir;
  };

  users.groups.lubelogger = {};

  networking.firewall.allowedTCPPorts = [port];

  services.traefik.dynamicConfigOptions.http.services.lubelogger = {
    loadBalancer = {
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.lubelogger = {
    entrypoints = "web";
    service = "lubelogger";
    rule = "Host(`lubelogger.${traefik_public_url}`)";

    middlewares = ["ssl-redirect" "ssl-header"];
  };

  services.traefik.dynamicConfigOptions.http.routers.lubelogger-secure = {
    entrypoints = "secureweb";
    service = "lubelogger";
    rule = "Host(`lubelogger.${traefik_public_url}`)";

    middlewares = ["default-headers"];
    tls.certResolver = "letsencrypt";
  };
}
