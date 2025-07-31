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

  # LAN clients view
  view lan {
    expr incidr(client_ip(), '10.6.0.0/16')
  }
  hosts {
    10.6.6.10 r3dm.com
    10.6.6.10 *.r3dm.com
  }
}

r3dm.com:${portString} {
  log
  errors

  # External clients view (default)
  view external {
    expr true
  }
  hosts {
    100.80.236.116 r3dm.com
    100.80.236.116 *.r3dm.com
  }
}
  '';
in {
  networking.firewall.allowedUDPPorts = [port];

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

  # Ensure the data directory exists
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${group} -"
  ];
}
