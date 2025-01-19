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

  sops.secrets.cloudflare_email = {};
  sops.secrets.cloudflare_dns_api_token = {};

  systemd.services.traefik.environment = {
    CF_API_EMAIL = config.sops.secrets.cloudflare_email.path;
    CF_DNS_API_TOKEN = config.sops.secrets.cloudflare_dns_api_token.path;
  };

  services.traefik = {
    enable = true;

    dataDir = "/mnt/storage/traefik";

    staticConfigOptions = {
      accessLog = {
        filePath = "/run/traefik/access.log";
        format = "json";

        fields = {
          defaultMode = "drop";
          names = {
            RouterName = "keep";
            ServiceName = "keep";
            RequestAddr = "keep";
            RequestHost = "keep";
            RequestMethod = "keep";
            RequestPath = "keep";
            RequestProtocol = "keep";
            RequestScheme = "keep";
            ClientHost = "keep";
          };
        };
      };

      log = {
        level = "DEBUG";
        filePath = "/run/traefik/traefik.log";
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
          http.tls.certResolver = "cloudflare";
        };
      };

      serversTransport.insecureSkipVerify = true;

      certificatesResolvers.cloudflare.acme = {
        email = config.sops.secrets.cloudflare_email.path;
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
        test-ipwhitelist.ipwhitelist.sourcerange = "192.168.1.1/24";
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
