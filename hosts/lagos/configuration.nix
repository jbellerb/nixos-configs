{ config, pkgs, ... }:

{
  networking.hostName = "lagos";

  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  # Extra Nix settings
  nix.settings.experimental-features = [ "ca-derivations" ];

  # Device-specific packages
  environment.systemPackages = with pkgs; [ wl-clipboard ];

  # Networking
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  # VPN
  secrets.lagos."wg0.nmconnection" = { };
  environment.etc."NetworkManager/system-connections/wg0.nmconnection" = {
    source = config.secrets.lagos."wg0.nmconnection".path;
  };

  # D-Bus
  services.dbus.implementation = "broker";

  # Graphics
  services.xserver = {
    enable = true;

    xkb.layout = "us";

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.libinput.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.pulseaudio.enable = false;

  # CUPS
  services.printing.enable = true;

  # Podman
  virtualisation.podman.enable = true;

  # Yubikey
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
  };

  # User
  secrets.lagos.waves-password.neededForUsers = true;
  users.users.waves = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
    hashedPasswordFile = config.secrets.lagos.waves-password.path;
  };
}
