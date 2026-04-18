{self, ...}: {
  flake.modules.nixos.services-base = {
    # Configure keymap in X11
    services.xserver.xkb.layout = "us";

    imports = with self.modules.nixos; [
      adguard
      atticd
      audiobookshelf
      concarne
      coredns
      home-assistant
      lubelogger
      openssh
      tailscale
      task
      taskbane
      tiab
      traefik
    ];
  };
}
