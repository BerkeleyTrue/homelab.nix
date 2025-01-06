{...}: {
  nixos-parts = {
    enable = true;

    defaults = {
      hostPlatform = "x86_64-linux";
      stateVersion = "24.05";
    };

    shared = {
      modules = [
        ./shared
      ];
    };

    hosts = {
      homelab = {
        username = "bt";
      };
    };
  };
}
