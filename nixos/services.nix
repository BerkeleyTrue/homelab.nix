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
}
