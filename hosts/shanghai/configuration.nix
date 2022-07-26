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
  networking.wireguard.interfaces = {
    wg0 =
      let
        hosts = config.metadata.hosts;

      in {
        ips = [
          "${hosts.shanghai.wireguard.address.ipv4}/32"
          "${hosts.shanghai.wireguard.address.ipv6}/128"
        ];
        privateKeyFile = config.sops.secrets.shanghai-wireguard-private.path;

        peers = [
          {
            publicKey = hosts.suez.wireguard.publicKey;
            presharedKeyFile = config.sops.secrets.wireguard-suez-shanghai-psk.path;
            allowedIPs = [ # TODO: network definitions in metadata
              "10.131.0.0/24"
              "fd3b:fe0b:d86b:a5ec::/64"
            ];
            endpoint =
              "${hosts.suez.ip_addr}:${toString hosts.suez.wireguard.port}";
            persistentKeepalive = 25;
          }
        ];
      };
  };

  networking.nameservers =
    with config.metadata.hosts.suez.wireguard.address; [ ipv4 ipv6 ];
}
