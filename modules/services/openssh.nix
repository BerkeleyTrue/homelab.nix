{
  flake.modules.nixos.openssh = {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      openFirewall = true;
    };
  };
}
