{ config, lib, ... }:

let
  hosts = config.metadata.hosts;

  peers = [
    "shanghai"
    "tugboat"
    "lagos"
    "paris"
    "carrier-1"
    "carrier-2"
    "carrier-3"
    "carrier-4"
    "carrier-5"
  ];

  mkPeer = peer: {
    PublicKey = hosts."${peer}".wireguard.publicKey;
    PresharedKeyFile = config.secrets.wireguard."suez-${peer}-psk".path;
    AllowedIPs = [
      "${hosts."${peer}".wireguard.address.ipv4}/32"
      "${hosts."${peer}".wireguard.address.ipv6}/128"
    ];
  };

in
{
  networking.firewall.allowedUDPPorts = [ hosts.suez.wireguard.port ];

  secrets.suez.wireguard-private.owner = "systemd-network";
  secrets.wireguard = builtins.listToAttrs (
    builtins.map (peer: lib.nameValuePair "suez-${peer}-psk" { owner = "systemd-network"; }) peers
  );
  systemd.network = {
    netdevs."50-wg0" = {
      netdevConfig = {
        Name = "wg0";
        Kind = "wireguard";
      };
      wireguardConfig = {
        ListenPort = hosts.suez.wireguard.port;
        PrivateKeyFile = config.secrets.suez.wireguard-private.path;
        RouteTable = "main";
      };
      wireguardPeers = builtins.map mkPeer peers;
    };
    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = [
        "${hosts.suez.wireguard.address.ipv4}/24"
        "${hosts.suez.wireguard.address.ipv6}/64"
      ];
      networkConfig.IPMasquerade = "both";
    };
  };
}
