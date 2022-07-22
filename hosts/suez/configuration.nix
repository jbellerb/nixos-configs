{ config, pkgs, lib, ... }:

{
  networking.hostName = "suez";
  sops.defaultSopsFile = secrets/secrets.yaml;

  imports = [
    ./hardware-configuration.nix
    ../common.nix

    ./modules/wireguard.nix
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
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Firewall setting
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
}
