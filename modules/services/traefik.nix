{
  flake.modules.nixos.traefik = {
    config,
    lib,
    ...
  }: let
    owner = config.users.users.traefik.name;
    group = config.users.users.traefik.group;
    public_url = config.traefik.public_url;
  in {
    options.traefik.public_url = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "r3dm.com";
    };

    sops.secrets.cloudflare_email = {
      mode = "0440";
      inherit owner group;
    };
    sops.secrets.cloudflare_dns_api_token = {
      mode = "0440";
      inherit owner group;
    };

    systemd.services.traefik.environment = {
      CF_API_EMAIL_FILE = config.sops.secrets.cloudflare_email.path;
      CF_DNS_API_TOKEN_FILE = config.sops.secrets.cloudflare_dns_api_token.path;
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
          # email = "cat ${config.sops.secrets.cloudflare_email.path}";
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
          rule = "Host(`traefik.${public_url}`)";
          middlewares = ["ssl-redirect" "ssl-header"];
          service = "api@internal";
        };

        http.routers.traefik-secure = {
          entrypoints = "secureweb";
          rule = "Host(`traefik.${public_url}`)";
          middlewares = ["default-headers"];
          tls.certresolver = "letsencrypt";
          service = "api@internal";
        };
      };
    };
  };
}
