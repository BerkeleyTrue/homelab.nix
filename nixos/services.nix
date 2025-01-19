{config, ...}: let
  traefik_public_url = "r3dm.com";
in {
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

    dataDir = "/mnt/storage/traefik";

    staticConfigOptions = {
      accessLog = true;
      log = {
        level = "DEBUG";
        filePath = "/var/log/traefik.log";
      };

      api = {
        dashboard = true;
        debug = true;
        insecure = true;
      };

      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entrypoints = {
        web.address = ":80";
        secureweb = {
          address = ":443";
          http.tls.certResolve = "cloudflare";
        };
      };

      serversTransport.insecureSkipVerify = true;

      certificatesResolvers.cloudflare.acme = {
        email = config.secrets.cloudflare_email;
        storage = "acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["9.9.9.9:53" "149.112.112.112:53"];
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        traefik-https-redirect.redirectscheme.scheme = "https";
        sslheader.headers.customrequestheaders.X-Forwarded-Proto = "https";
        test-ipwhitelist.ipwhitelist.sourcerange = 192.168.1.1/24;
      };

      http.routers.traefik = {
        entrypoints = "web";
        rule = "Host(`traefik.${traefik_public_url}`)";
        middlewares = "traefik-https-redirect";
      };

      http.routers.traefik-secure = {
        entrypoints = "secureweb";
        rule = "Host(`traefik.${traefik_public_url}`)";
        tls = {
          certresolver = "cloudflare";
          domains = [
            {
              main = "traefik.${traefik_public_url}}";
              sans = "*.${traefik_public_url}";
            }
          ];
        };
        servcie = "api@internal";
      };
    };
  };
}
