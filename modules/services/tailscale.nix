{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      # automatically sets the IP forwarding sysctls
      useRoutingFeatures = "server";
    };
  };
}
