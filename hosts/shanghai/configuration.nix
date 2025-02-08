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

  # Device-specific packages
  environment.systemPackages = with pkgs; [ duperemove ];

  # Networking
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Container NAT
  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = [ "ve-+" ];
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

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
