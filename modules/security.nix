{
  flake.modules.nixos.security = {
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=60
    '';
  };
}
