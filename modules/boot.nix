{
  flake.modules.nixos.boot = {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = ["dm-snapshot"];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];
  };
}
