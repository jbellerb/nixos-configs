{ config, lib, ... }:

with lib;

let
  hosts = config.metadata.hosts;
  hostname = config.networking.hostName;

in
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
    secrets."${hostname}".wireguard-private.owner = "systemd-network";
    secrets.wireguard."suez-${hostname}-psk".owner = "systemd-network";
    systemd.network = {
      netdevs."30-wg0" = {
        netdevConfig = {
          Name = "wg0";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = config.secrets."${hostname}".wireguard-private.path;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            PublicKey = hosts.suez.wireguard.publicKey;
            PresharedKeyFile = config.secrets.wireguard."suez-${hostname}-psk".path;
            AllowedIPs = [
              "${hosts.suez.wireguard.address.ipv4}/24"
              "${hosts.suez.wireguard.address.ipv6}/64"
            ];
            Endpoint = "${hosts.suez.ipAddr}:${toString hosts.suez.wireguard.port}";
            PersistentKeepalive = mkIf config.services.wireguard.keepalive 25;
          }
        ];
      };
      networks."30-wg0" = {
        name = "wg0";
        address = [
          "${hosts."${hostname}".wireguard.address.ipv4}/32"
          "${hosts."${hostname}".wireguard.address.ipv6}/128"
        ];
        dns = mkIf config.services.wireguard.dns (
          with hosts.suez.wireguard.address;
          [
            ipv4
            ipv6
          ]
        );
      };
    };
  };
}
