{
  lib,
  pkgs,
  ...
}: let
  port = 5533;
  homelabIp = "10.6.7.10";
  homelabTailscaleIp = "100.80.236.116";
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

r3dm.com {
  log
  errors

  # LAN clients view
  view lan {
    expr incidr(client_ip(), '10.6.0.0/16')
  }
  template IN A {
    match ".*r3dm.com\.$"
    answer "{{.Name}} 60 IN A ${homelabIp}"
  }
}

r3dm.com {
  log
  errors

  # External clients view (default)
  template IN A {
    match ".*r3dm.com\.$"
    answer "{{.Name}} 60 IN A ${homelabTailscaleIp}"
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
