{
  flake.modules.nixos.networking = {
    config,
    lib,
    ...
  }: let
    hostName = config.homelab.hostName;
  in {
    options.homelab.hostName = lib.mkOption {
      type = lib.types.str;
    };
    networking.hostName = hostName; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [80 443];
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  };
}
