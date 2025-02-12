{ config, pkgs, ... }:

{
  networking.hostName = "shanghai";

  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../server-common.nix

    ./modules/docker.nix
    ./modules/git.nix
    ./modules/gonic.nix
    ./modules/jellyfin.nix
    ./modules/nginx.nix
    ./modules/pounce.nix
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
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Container NAT
  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = [ "ve-+" ];
  };

  # VPN
  secrets.shanghai.wireguard-private = { };
  secrets.wireguard.suez-shanghai-psk = { };
  services.wireguard = {
    enable = true;
    keepalive = true;
  };
  networking.nameservers = with config.metadata.hosts.suez.wireguard.address; [
    ipv4
    ipv6
  ];
}
