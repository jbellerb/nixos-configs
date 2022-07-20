{ config, pkgs, lib, ... }:

{
  networking.hostName = "suez";

  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  ########################
  # Device configuration #
  ########################

  # Device-specific packages
  environment.systemPackages = with pkgs; [ ];

  ##############
  # Networking #
  ##############

  # DHCP
  networking.useDHCP = true;

  # Firewall setting
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = true;
}
