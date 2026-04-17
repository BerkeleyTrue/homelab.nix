{
  flake.modules.nixos.filesystem = {
    lib,
    config,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/322b29e7-85b9-45bd-b673-8b39cb4f53b7";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/467E-0219";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/52f4789b-836e-4748-8141-e86caf5f264a";}
    ];

    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
