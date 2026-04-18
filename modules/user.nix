{
  flake.modules.homeManager.user = {lib, ...}: {
    options.homelab.username = lib.mkOption {
      type = lib.types.str;
    };
  };

  flake.modules.nixos.user = {
    config,
    lib,
    pkgs,
    ...
  }: let
    username = config.homelab.username;
  in {
    options.homelab.username = lib.mkOption {
      type = lib.types.str;
    };

    config.users.defaultUserShell = pkgs.zsh;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    config.users.users.${username} = {
      isNormalUser = true;
      extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        gh
      ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    config.environment.systemPackages = with pkgs; [
      neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      curl
      wget
      git
      zsh
      usbutils
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    config.programs.zsh.enable = true;
  };
}
