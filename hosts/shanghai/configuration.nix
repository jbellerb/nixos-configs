{ config, pkgs, lib, ... }:

{
  networking.hostName = "shanghai";
  sops.defaultSopsFile = secrets/secrets.yaml;

  imports = [
    ./hardware-configuration.nix
    ../common.nix

    ./modules/docker.nix
    ./modules/git.nix
    ./modules/jellyfin.nix
    ./modules/pounce.nix
    ./modules/samba.nix
  ];

  ########################
  # Device configuration #
  ########################

  # Device-specific packages
  environment.systemPackages = with pkgs; [
    bedup
  ];

  ##############
  # Networking #
  ##############

  # DHCP
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Firewall setting
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 139 445 8080 8096 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  networking.firewall.allowPing = true;

  # Container NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp3s0";
  networking.nat.internalInterfaces = [ "ve-+" ];

  # VPN
  sops.secrets.shanghai-wireguard-private = { };
  sops.secrets.shanghai-wireguard-preshared = { };
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.49.0.6/32" ];
      privateKeyFile = config.sops.secrets.shanghai-wireguard-private.path;
      dns = [ "172.16.145.102" ];
      peers = [
        {
          publicKey = "pUaLpcUF6HmVjAq4ah65oRtXmhxGiwU/g+aAJ1i+A3k=";
          presharedKeyFile = config.sops.secrets.shanghai-wireguard-preshared.path;
          allowedIPs = [ "10.49.0.0/24" "172.16.145.102/32" ];
          endpoint = "0.0.0.0:12345";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
