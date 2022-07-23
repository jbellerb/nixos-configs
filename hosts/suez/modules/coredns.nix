{ config, pkgs, ... }:

let
  hosts = config.metadata.hosts;

  zoneFile = pkgs.writeText "home.zone" ''
    $TTL 60
    $ORIGIN home.

    @ IN SOA suez.home. suez.home. (
           2022072301 ; serial
                28800 ; refresh
                 7200 ; retry
               864000 ; expire
                86400 ; minimum
    )

    suez.home. IN A ${hosts.suez.wireguard.address.ipv4}
    suez.home. IN AAAA ${hosts.suez.wireguard.address.ipv6}
    ${hosts.suez.wireguard.address.ipv4}.in-addr.arpa. IN PTR suez.home.
  '';

in {
  services.coredns = {
    enable = true;
    config = ''
      . {
        bind ${hosts.suez.wireguard.address.ipv4}
        bind ${hosts.suez.wireguard.address.ipv6}
        errors

        local
        forward . tls://1.1.1.1 tls://1.0.0.1 {
          tls_servername cloudflare-dns.com
          health_check 5s
        }

        cache {
          prefetch 5 10m 10%
        }
      }

      home {
        bind ${hosts.suez.wireguard.address.ipv4}
        bind ${hosts.suez.wireguard.address.ipv6}
        errors

        file ${zoneFile}
      }
    '';
  };
}
