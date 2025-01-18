{...}: {
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.taskchampion-sync-server = {
    enable = true;
    port = 10222;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  services.tailscale = {
    enable = true;
  };

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      accessLog = true;
      log = {
        level = "TRACE";
        filePath = "/var/log/traefik.log";
      };

      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entrypoints = {
        web.address = ":80";
        secureweb = {
          address = ":443";
        };
      };

      api = {
        dashboard = true;
        debug = true;
        insecure = true;
      };
    };
  };
}
