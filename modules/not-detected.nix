{
  flake.modules.nixos.not-detected = {modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  };
}
