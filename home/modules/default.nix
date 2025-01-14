{...}: {
  imports = [
    ./commandline.nix
    ./services.nix
    ./apps.nix
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
