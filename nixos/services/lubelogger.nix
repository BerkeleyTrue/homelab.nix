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
  services.lubelogger.settings = {
    DOTNET_CONTENTROOT = dataDir;
    Kestrel__Endpoints__Http__Url = "http://localhost:${toString port}";
  };

  systemd.services.lubelogger = {
    description = "Lubelogger, a self-hosted, open-source, web-based vehicle maintenance and fuel milage tracker";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {};

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
      # BindPaths = [
      #   "${cfg.dataDir}/config:${cfg.package}/lib/lubelogger/config"
      #   "${cfg.dataDir}/data:${cfg.package}/lib/lubelogger/data"
      #   "${cfg.dataDir}/temp:${cfg.package}/lib/lubelogger/wwwroot/temp"
      #   "${cfg.dataDir}/images:${cfg.package}/lib/lubelogger/wwwroot/images"
      # ];
    };
  };

  # systemd.tmpfiles.rules = [
  #   "d '${cfg.dataDir}/config' 0770 '${cfg.user}' '${cfg.group}' - -"
  #   "d '${cfg.dataDir}/data' 0770 '${cfg.user}' '${cfg.group}' - -"
  #   "d '${cfg.dataDir}/temp' 0770 '${cfg.user}' '${cfg.group}' - -"
  #   "d '${cfg.dataDir}/images' 0770 '${cfg.user}' '${cfg.group}' - -"
  # ];

  users.users.lubelogger = {
    inherit group;
    isSystemUser = true;
    home = dataDir;
  };

  users.groups.lubelogger = {};

  networking.firewall.allowedTCPPorts = [port];

  services.traefik.dynamicConfigOptions.http.routers.lubelogger = {
    entrypoints = "web";
    rule = "Host(`lubelogger.${traefik_public_url}`)";
    service = "lubelogger";
    middlewares = ["default-headers"];
  };

  services.traefik.dynamicConfigOptions.http.services.lubelogger = {
    loadBalancer = {
      servers = [{url = "http://0.0.0.0:${toString port}";}];
      passHostHeader = true;
    };
  };
}
