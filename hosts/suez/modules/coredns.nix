{ config, pkgs, ... }:

let
  hosts = config.metadata.hosts;

  zoneFile = pkgs.writeText "home.zone" ''
    $TTL 60
    $ORIGIN home.

    @ IN SOA suez.home. suez.home. (
           2022072502 ; serial
                28800 ; refresh
                 7200 ; retry
               864000 ; expire
                86400 ; minimum
    )

    suez.home. IN A ${hosts.suez.wireguard.address.ipv4}
    suez.home. IN AAAA ${hosts.suez.wireguard.address.ipv6}
    ${hosts.suez.wireguard.address.ipv4}.in-addr.arpa. IN PTR suez.home.

    shanghai.home. IN A ${hosts.shanghai.wireguard.address.ipv4}
    shanghai.home. IN AAAA ${hosts.shanghai.wireguard.address.ipv6}
    ${hosts.shanghai.wireguard.address.ipv4}.in-addr.arpa. IN PTR shanghai.home.

    *.shanghai.home. CNAME shanghai.home.
  '';

in {
  networking.firewall.allowedUDPPorts = [ 53 ];

  users = {
    users.coredns = {
      isSystemUser = true;

      group = config.users.groups.coredns.name;
      extraGroups = [ config.users.groups.keys.name ];
    };

    groups.coredns = { };
  };

  services.adlist = {
    enable = true;
    path = "/var/lib/coredns/hosts.blacklist";
  };

  systemd.services.coredns.serviceConfig.User = "coredns";
  systemd.services.coredns.serviceConfig.StateDirectory = "coredns";

  sops.secrets."Khome.+013+34119.key" = { owner = "coredns"; };
  sops.secrets."Khome.+013+34119.private" = { owner = "coredns"; };
  services.coredns = {
    enable = true;
    config = ''
      . {
        bind ${hosts.suez.wireguard.address.ipv4}
        bind ${hosts.suez.wireguard.address.ipv6}
        errors

        hosts /var/lib/coredns/hosts.blacklist {
          reload 3600s
          no_reverse
          fallthrough
        }

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

        file /var/lib/coredns/db.home.signed home

        sign ${zoneFile} {
          key file ${config.sops.secrets."Khome.+013+34119.key".path}
        }
      }
    '';
  };
}
