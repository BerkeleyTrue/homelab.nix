{self, ...}: {
  flake.modules.nixos.homelab = {};

  configurations.nixos.homelab = {
    modules = with self.modules.nixos; [
      boot
      filesystem
      homelab
      networking
      nix
      security
      snapraid
      sops
      system
      time
      user
    ];
  };
}
