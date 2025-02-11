{ config, pkgs, ... }:

let
  hosts = config.metadata.hosts;

  mkPeer = peer: {
    publicKey = hosts."${peer}".wireguard.publicKey;
    presharedKeyFile = config.secrets.wireguard."suez-${peer}-psk".path;
    allowedIPs = [
      "${hosts."${peer}".wireguard.address.ipv4}/32"
      "${hosts."${peer}".wireguard.address.ipv6}/128"
    ];
  };

in
{
  networking.firewall.allowedUDPPorts = [ hosts.suez.wireguard.port ];

  networking.nat.enable = true;
  networking.nat.enableIPv6 = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];

  secrets.suez.wireguard-private = { };
  secrets.wireguard.suez-shanghai-psk = { };
  secrets.wireguard.suez-tugboat-psk = { };
  secrets.wireguard.suez-lagos-psk = { };
  secrets.wireguard.suez-paris-psk = { };
  secrets.wireguard.suez-carrier-1-psk = { };
  secrets.wireguard.suez-carrier-2-psk = { };
  secrets.wireguard.suez-carrier-3-psk = { };
  secrets.wireguard.suez-carrier-4-psk = { };
  secrets.wireguard.suez-carrier-5-psk = { };
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [
        "${hosts.suez.wireguard.address.ipv4}/24"
        "${hosts.suez.wireguard.address.ipv6}/64"
      ];
      listenPort = hosts.suez.wireguard.port;
      privateKeyFile = config.secrets.suez.wireguard-private.path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${hosts.suez.wireguard.address.ipv4}/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${hosts.suez.wireguard.address.ipv6}/64 -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${hosts.suez.wireguard.address.ipv4}/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${hosts.suez.wireguard.address.ipv6}/64 -o eth0 -j MASQUERADE
      '';

      peers = map mkPeer (
        with hosts;
        [
          "shanghai"
          "tugboat"
          "lagos"
          "paris"
          "carrier-1"
          "carrier-2"
          "carrier-3"
          "carrier-4"
          "carrier-5"
        ]
      );
    };
  };
}
