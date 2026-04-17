{self, ...}: {
  flake.modules.nixos.base = {
    # Configure keymap in X11
    services.xserver.xkb.layout = "us";

    imports = with self.modules.nixos; [
      adguard
      audiobookshelf
      concarne
      coredns
      home-assistant
      lubelogger
      openssh
      tailscale
      task
      taskbane
      traefik
    ];
  };
}
