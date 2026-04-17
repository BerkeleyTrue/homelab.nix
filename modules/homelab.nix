{self, ...}: {
  flake.modules.nixos.homelab = {
    config,
    lib,
    ...
  }: {
    homelab.hostName = "homelab";
    homelab.username = "bt";
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "24.05";

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];

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

    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

    # lvm snapshots
    boot.initrd.kernelModules = ["dm-snapshot"];
    # virtualization
    boot.kernelModules = ["kvm-intel"];
  };

  configurations.nixos.homelab = {
    modules = with self.modules.nixos; [
      boot
      filesystem
      homelab
      locale
      networking
      nix
      security
      snapraid-homelab
      sops
      system
      user
    ];
  };
}
