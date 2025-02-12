{ config, pkgs, ... }:

{
  # systemd
  systemd = {
    enableEmergencyMode = false;
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # Networking
  networking.useNetworkd = true;
  systemd.network.wait-online.enable = false;
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  # Firewall
  networking.firewall.allowPing = true;

  # Remove some desktop things
  environment.stub-ld.enable = false;
  fonts.fontconfig.enable = false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
