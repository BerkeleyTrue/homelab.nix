{inputs, ...}: {
  home-manager-parts = {
    inherit (inputs) home-manager;
    enable = true;
    exposePackages = true;

    defaults = {
      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      stateVersion = "22.11";
      system = "x86_64-linux";
    };

    shared = {profile, ...}: {
      modules = [
        inputs.sops-nix.homeManagerModules.sops
         ../modules/sops.nix
      ];
      extraSpecialArgs = {
        inherit profile;
      };
    };

    profiles = {
      # main homelab
      homelab = {
        username = "bt";
        modules = [
          ./modules
        ];
        specialArgs = {};
      };
    };
  };
}
