{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  # Kernel modules
  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "xen_blkfront"
      ];
      kernelModules = [ "nvme" ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
    kernelParams = [
      "console=ttyS0,115200n8"
      "random.trust_cpu=on"
    ];
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 2;

  # Drives
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/bfe15554-f93e-4a44-847b-29cd914e01ab";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/d726071f-b770-48f2-8f6f-3016a0245f0f";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/0DD3-9DEC";
      fsType = "vfat";
    };
  };
  boot.tmp.cleanOnBoot = true;

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 2048;
    }
  ];
}
