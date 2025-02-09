{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

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
      kernelModules = [ "i915" ];
    };
    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "ntfs3" ];
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ ];
    supportedFilesystems = {
      bcachefs = true;
      ntfs-3g = true;
    };
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
  boot.tmp.useTmpfs = true;
  swapDevices = [ ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Laptop
  services.throttled.enable = true;
  services.fstrim.enable = true;
  hardware.trackpoint.enable = true;
  hardware.trackpoint.emulateWheel = true;

  # GPU
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
    vpl-gpu-rt
  ];

  # Firmware
  hardware.cpu.intel.updateMicrocode = true;
  services.fwupd.enable = true;
}
