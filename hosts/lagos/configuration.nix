{ config, pkgs, ... }:

{
  networking.hostName = "lagos";
  sops.defaultSopsFile = secrets/secrets.yaml;
  sops.age.keyFile = "/home/waves/.config/sops/age/keys.txt";

  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  # Device-specific packages
  environment.systemPackages = with pkgs; [ ];

  # Networking
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall.enable = true;

  # VPN
  sops.secrets."wg0.nmconnection" = { };
  environment.etc."NetworkManager/system-connections/wg0.nmconnection" = {
    source = config.sops.secrets."wg0.nmconnection".path;
  };

  # Graphics
  services.xserver = {
    enable = true;

    layout = "us";
    libinput.enable = true;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # CUPS
  services.printing.enable = true;

  # User
  sops.secrets.waves-password = { neededForUsers = true; };
  users.users.waves = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    passwordFile = config.sops.secrets.waves-password.path;
  };
}
