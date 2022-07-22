{ config, pkgs, ... }:

let
  hosts = config.metadata.hosts;

  mkPeer = peer: {
    publicKey = peer.wireguard.publicKey;
    allowedIPs = [
      "${peer.wireguard.address.ipv4}/32"
      "${peer.wireguard.address.ipv6}/128"
    ];
  };

in {
  networking.firewall.allowedUDPPorts = [ hosts.suez.wireguard.port ];

  networking.nat.enable = true;
  networking.nat.enableIPv6 = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];

  sops.secrets.suez-wireguard-private = { };
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [
        "${hosts.suez.wireguard.address.ipv4}/24"
        "${hosts.suez.wireguard.address.ipv6}/64"
      ];
      listenPort = hosts.suez.wireguard.port;
      privateKeyFile = config.sops.secrets.suez-wireguard-private.path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${hosts.suez.wireguard.address.ipv4}/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${hosts.suez.wireguard.address.ipv6}/64 -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${hosts.suez.wireguard.address.ipv4}/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${hosts.suez.wireguard.address.ipv6}/64 -o eth0 -j MASQUERADE
      '';

      peers = builtins.map mkPeer (with hosts; [
        tugboat
        lagos
      ]);
    };
  };
}
