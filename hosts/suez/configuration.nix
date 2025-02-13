{ config, pkgs, ... }:

{
  networking.hostName = "suez";

  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../server-common.nix

    ./modules/coredns.nix
    ./modules/wireguard.nix
  ];

  # Device-specific packages
  environment.systemPackages = with pkgs; [ ];

  # Networking
  systemd.network.networks."10-ens5" = {
    matchConfig.Name = "ens5";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    ntp = [ "169.254.169.123" ]; # EC2's time server
  };
}
