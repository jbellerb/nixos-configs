{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  # Kernel modules
  boot = {
    initrd = {
      availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ata_piix"
        "firewire_ohci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 4;

  # Drives
  fileSystems =
    let
      mkSubvol = subvol: {
        device = "/dev/disk/by-uuid/d17a3053-16e0-412b-a44f-b030c5c02eda";
        fsType = "btrfs";
        options = [ "defaults,noatime,subvol=${subvol}" ];
      };

    in {
      "/" = mkSubvol "@";
      "/nix" = mkSubvol "@nix";
      "/.snapshots" = mkSubvol "@snapshots/root_snaps";
      "/home" = mkSubvol "@home";
      "/home/.snapshots" = mkSubvol "@snapshots/home_snaps";
      "/var/btrfs_root" = mkSubvol "/";
    };

  boot.loader.grub.device = "/dev/sda";

  boot.tmpOnTmpfs = true;

  swapDevices = [
    { device = "/dev/disk/by-uuid/782c7ab9-f15d-4cbe-8bc5-ff415dd68841"; }
  ];

  # Drive maintenence
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  services.snapper.configs =
    let
      schedule = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_HOURLY="12"
        TIMELINE_LIMIT_DAILY="7"
        TIMELINE_LIMIT_WEEKLY="4"
        TIMELINE_LIMIT_MONTHLY="6"
        TIMELINE_LIMIT_YEARLY="0"
      '';

    in {
      "root" = {
        subvolume = "/";
        extraConfig = schedule;
      };
      "home" = {
        subvolume = "/home";
        extraConfig = schedule;
      };
    };
}
