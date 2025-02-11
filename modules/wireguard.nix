{ config, lib, ... }:

with lib;

{
  options.services.wireguard = {
    enable = mkEnableOption "connecting to the WireGuard VPN via Suez";
    dns = mkOption {
      type = types.bool;
      default = false;
      description = "Use Suez as the primary nameserver";
    };
    keepalive = mkOption {
      type = types.bool;
      default = false;
      description = "Keep the connection to the VPN always open";
    };
  };

  config = mkIf config.services.wireguard.enable {
    networking.nameservers = mkIf config.services.wireguard.dns (
      with config.metadata.hosts.suez.wireguard.address;
      [
        ipv4
        ipv6
      ]
    );

    networking.wireguard.interfaces.wg0 =
      let
        hostname = config.networking.hostName;
        hosts = config.metadata.hosts;

      in
      {
        ips = [
          "${hosts."${hostname}".wireguard.address.ipv4}/32"
          "${hosts."${hostname}".wireguard.address.ipv6}/128"
        ];
        privateKeyFile = config.secrets."${hostname}".wireguard-private.path;

        peers = [
          {
            publicKey = hosts.suez.wireguard.publicKey;
            presharedKeyFile = config.secrets.wireguard."suez-${hostname}-psk".path;
            allowedIPs = [
              # TODO: network definitions in metadata
              "10.131.0.0/24"
              "fd3b:fe0b:d86b:a5ec::/64"
            ];
            endpoint = "${hosts.suez.ip_addr}:${toString hosts.suez.wireguard.port}";
            persistentKeepalive = mkIf config.services.wireguard.keepalive 25;
          }
        ];
      };
  };
}
