{
  lib,
  pkgs,
  ...
}: let
  port = 5533;
  portString = toString port;
  user = "coredns";
  group = "coredns";
  dataDir = "/mnt/storage/coredns";
  config = pkgs.writeText "Corefile" ''
.:${portString} {
  log
  errors
  # no forward, fail on all domains not configured
}

r3dm.com:${portString} {
  log
  errors

  # View for local LAN clients
  acl local {
    cidr 10.6.0.0/16
  }

  # Match LAN clients
  view lan {
    acl local
    template IN A {
      match .*\.r3dm\.com
      answer "{{ .Name }} 60 IN A 10.6.6.10"
      fallthrough
    }
  }

  # Default view for all others (Tailscale, etc.)
  view tailscale {
    template IN A {
      match .*\.r3dm\.com
      answer "{{ .Name }} 60 IN A 100.80.236.116"
      fallthrough
    }
  }
}
  '';
in {
  systemd.services.coredns = {
    description = "CoreDNS DNS server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      description = "CoreDNS DNS server";
      StateDirectory = baseNameOf dataDir;
      WorkingDirectory = dataDir;
      ExecStart = "${lib.getBin pkgs.coredns}/bin/coredns -conf=${config} -dns.port=${toString port}";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
      Restart = "on-failure";

      PermissionsStartOnly = true;
      LimitNPROC = 512;
      LimitNOFILE = 1048576;
      NoNewPrivileges = true;
    };
  };

  users.users.coredns = {
    inherit group;
    isSystemUser = true;
    home = dataDir;
  };

  users.groups.coredns = {};
}
