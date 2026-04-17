{self, ...}: {
  flake.modules.nixos.system = {
    system.stateVersion = "24.05";

    system.autoUpgrade = {
      enable = true;
      flake = self.outPath;
      dates = "weekly";
      randomizedDelaySec = "45min";
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
        "-L" # print build logs
      ];
    };
  };
}
