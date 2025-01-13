{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mergerfs
  ];

  fileSystems."/mnt/pari1" = {
    device = "/dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N0_WD-WX62D10LE1SE";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk1" = {
    device = "/dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N0_WD-WX62D10LEJHE";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk2" = {
    device = "/dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N0_WD-WX62D10LEKV3";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk3" = {
    device = "/dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N0_WD-WX62D10LEN1A";
    fsType = "ext4";
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/disk1:/mnt/disk2:/mnt/disk3";
    options = [
      "direct_io"
      "defaults"
      "allow_other"
      "minfreespace=50G"
      "fsname=mergerfs"
      "category.create=mfs" # Create new files on the disk with the most free space
    ];
  };

  services.snapraid = {
    enable = true;
    contentFiles = [
      "/mnt/pari1/.snapraid.content"
      "/mnt/disk1/.snapraid.content"
    ];

    dataDisks = {
      d1 = "/mnt/disk1";
      d2 = "/mnt/disk2";
      d3 = "/mnt/disk3";
    };

    parityFiles = [
      "mnt/pari1/snapraid.parity"
    ];

    exclude = [
      "*.unrecoverable"
      "*.bak"
      "/lost+found/"
      "*.!sync"
      "/tmp/"
      "*.content"
      "aquota.group"
      "aquota.user"
    ];

    touchBeforeSync = true;

    extraConfig = ''
      autosave 256
    '';
  };
}
