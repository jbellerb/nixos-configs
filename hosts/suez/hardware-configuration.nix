{ config, lib, modulesPath, ... }:

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
  nix.maxJobs = lib.mkDefault 1;

  # Drives
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9451d968-8716-47ca-84d5-68b5c79f61e8";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/xvda";

  boot.tmpOnTmpfs = true;

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = true;
}
