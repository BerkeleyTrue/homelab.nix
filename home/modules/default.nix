{...}: {
  imports = [
    ./commandline.nix
    ./servies.nix
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
