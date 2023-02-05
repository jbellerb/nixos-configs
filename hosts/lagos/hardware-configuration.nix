{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  # Kernel modules
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "bcachefs" "ntfs" ];
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 4;

  # Drives
  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p7";
      fsType = "bcachefs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/c879a081-12b1-4433-8bd2-4f6013580a87";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/98B4-0992";
      fsType = "vfat";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.tmpOnTmpfs = true;

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = "powersave";
  hardware.video.hidpi.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.fwupd.enable = true;
  services.throttled.enable = true;
}
