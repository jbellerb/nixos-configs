{ pkgs, ... }:

{
  networking.hostName = "suez";

  imports = [
    ./hardware-configuration.nix
    ../common.nix

    ./modules/coredns.nix
    ./modules/wireguard.nix
  ];

  # Device-specific packages
  environment.systemPackages = with pkgs; [ ];

  # Networking
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
