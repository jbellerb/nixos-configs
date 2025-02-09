{ config, pkgs, ... }:

let
  hosts = config.metadata.hosts;

  mkPeer = peer: {
    publicKey = hosts."${peer}".wireguard.publicKey;
    presharedKeyFile = config.sops.secrets."wireguard-suez-${peer}-psk".path;
    allowedIPs = [
      "${hosts."${peer}".wireguard.address.ipv4}/32"
      "${hosts."${peer}".wireguard.address.ipv6}/128"
    ];
  };

  pskSecret = peerClass: {
    sopsFile = ../../secrets/keys + "/wg-suez-${peerClass}-psk.yaml";
  };

in
{
  networking.firewall.allowedUDPPorts = [ hosts.suez.wireguard.port ];

  networking.nat.enable = true;
  networking.nat.enableIPv6 = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];

  sops.secrets.suez-wireguard-private = { };
  sops.secrets.wireguard-suez-shanghai-psk = pskSecret "shanghai";
  sops.secrets.wireguard-suez-tugboat-psk = pskSecret "unmanaged";
  sops.secrets.wireguard-suez-lagos-psk = pskSecret "lagos";
  sops.secrets.wireguard-suez-paris-psk = pskSecret "unmanaged";
  sops.secrets.wireguard-suez-carrier-1-psk = pskSecret "unmanaged";
  sops.secrets.wireguard-suez-carrier-2-psk = pskSecret "unmanaged";
  sops.secrets.wireguard-suez-carrier-3-psk = pskSecret "unmanaged";
  sops.secrets.wireguard-suez-carrier-4-psk = pskSecret "unmanaged";
  sops.secrets.wireguard-suez-carrier-5-psk = pskSecret "unmanaged";
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
