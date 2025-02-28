{ config, pkgs, ... }:

{
  networking.hostName = "shanghai";

  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../server-common.nix

    ./modules/apprise.nix
    ./modules/docker.nix
    ./modules/git.nix
    ./modules/gonic.nix
    ./modules/jellyfin.nix
    ./modules/miniflux.nix
    ./modules/nginx.nix
    ./modules/pounce.nix
    ./modules/postgresql.nix
    ./modules/samba.nix
  ];

  # Device-specific packages
  environment.systemPackages = with pkgs; [ duperemove ];

  # systemd
  systemd.watchdog = {
    runtimeTime = "30s";
    rebootTime = "1m";
    kexecTime = "1m";
  };

  # Networking
  systemd.network.networks."10-enp3s0" = {
    name = "enp3s0";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
      IPv4Forwarding = true;
      IPv6Forwarding = true;
    };
  };

  # VPN
  services.wireguard = {
    enable = true;
    dns = true;
    keepalive = true;
  };
}
