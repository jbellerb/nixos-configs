{ config, pkgs, ... }:

{
  networking.hostName = "shanghai";
  sops.defaultSopsFile = secrets/secrets.yaml;

  imports = [
    ./hardware-configuration.nix
    ../common.nix

    ./modules/docker.nix
    ./modules/git.nix
    ./modules/jellyfin.nix
    ./modules/nginx.nix
    ./modules/pounce.nix
    ./modules/samba.nix
  ];

  ########################
  # Device configuration #
  ########################

  # Device-specific packages
  environment.systemPackages = with pkgs; [
    duperemove
  ];

  ##############
  # Networking #
  ##############

  # DHCP
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Firewall setting
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # Container NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp3s0";
  networking.nat.internalInterfaces = [ "ve-+" ];

  # VPN
  sops.secrets.shanghai-wireguard-private = { };
  sops.secrets.wireguard-suez-shanghai-psk = {
    sopsFile = ../secrets/keys/wg-suez-shanghai-psk.yaml;
  };
  services.wireguard.enable = true;
  services.wireguard.keepalive = true;

  networking.nameservers =
    with config.metadata.hosts.suez.wireguard.address; [ ipv4 ipv6 ];
}
