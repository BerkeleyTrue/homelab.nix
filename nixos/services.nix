{config, ...}: let
  traefik_public_url = "r3dm.com";
in {
  imports = [
    ./services/lubelogger.nix
    ./services/home-assistant.nix
  ];
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.taskchampion-sync-server = {
    enable = true;
    port = 10222;
    openFirewall = true;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  sops.secrets.cloudflare_email = {};
  sops.secrets.cloudflare_dns_api_token = {};

  systemd.services.traefik.environment = {
    CF_API_EMAIL = config.sops.secrets.cloudflare_email.path;
    CF_DNS_API_TOKEN = config.sops.secrets.cloudflare_dns_api_token.path;
  };

  services.traefik = {
    enable = true;

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
          http.tls.certResolver = "letsencrypt";
        };
      };

      serversTransport.insecureSkipVerify = true;

      certificatesResolvers.letsencrypt.acme = {
        email = "${config.sops.secrets.cloudflare_email.path}";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["9.9.9.9:53" "149.112.112.112:53"];
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        ssl-redirect.redirectscheme.scheme = "https";
        ssl-header.headers.customrequestheaders.X-Forwarded-Proto = "https";
        default-whitelist.ipwhitelist.sourcerange = [];

        default-headers.headers = {
          frameDeny = true;
          browserXssFilter = true;
          contentTypeNosniff = true;
          forceSTSHeader = true;
          stsIncludeSubdomains = true;
          stsPreload = true;
          stsSeconds = "15552000";
          customFrameOptionsValue = "SAMEORIGIN";
        };
      };

      http.routers.traefik = {
        entrypoints = "web";
        rule = "Host(`traefik.${traefik_public_url}`)";
        middlewares = ["ssl-redirect" "ssl-header"];
        service = "api@internal";
      };

      http.routers.traefik-secure = {
        entrypoints = "secureweb";
        rule = "Host(`traefik.${traefik_public_url}`)";
        tls = {
          certresolver = "letsencrypt";
          domains = [
            {
              main = "traefik.${traefik_public_url}}";
              sans = "*.${traefik_public_url}";
            }
          ];
        };
        service = "api@internal";
      };
    };
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedUDPPorts = [53];

  services.traefik.dynamicConfigOptions.http.routers.adguard = {
    entrypoints = "web";
    rule = "Host(`adguard.${traefik_public_url}`)";
    service = "adguard";
    middlewares = ["default-headers"];
  };

  services.traefik.dynamicConfigOptions.http.services.adguard = {
    loadBalancer = {
      servers = [{url = "http://127.0.0.1:3000";}];
      passHostHeader = true;
    };
  };
}
