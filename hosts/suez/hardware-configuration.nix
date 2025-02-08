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
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 1;

  # Drives
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9451d968-8716-47ca-84d5-68b5c79f61e8";
    fsType = "ext4";
  };
  boot.tmp.useTmpfs = true;
  swapDevices = [ { device = "/var/swapfile"; size = 2048; } ];

  # Bootloader
  boot.loader.grub.device = "/dev/xvda";

  # Firmware
  hardware.cpu.intel.updateMicrocode = true;
}
