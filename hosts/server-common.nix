{ config, pkgs, ... }:

{
  # Reboot on panic
  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
    "vga=0x317"
    "nomodeset"
  ];

  # systemd
  systemd = {
    enableEmergencyMode = false;
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # Networking
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };
  networking.useDHCP = false;

  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  # Firewall
  networking.firewall.allowPing = true;
  networking.nftables.enable = false; # TODO: enable once off Docker

  # Remove some desktop things
  environment.stub-ld.enable = false;
  fonts.fontconfig.enable = false;
  services.udisks2.enable = false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
  documentation = {
    dev.enable = false;
    doc.enable = false;
  };
}
