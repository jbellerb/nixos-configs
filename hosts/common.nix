{ config, lib, pkgs, ... }:

with lib;

{
  system.stateVersion = "22.05";
  # system.autoUpgrade.enable = true;

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    trustedUsers = [ "root" "@wheel" ];

    binaryCaches = [ "https://nix-community.cachix.org" ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    gc.automatic = true;
    optimise.automatic = true;
  };

  metadata = import ./metadata.nix;

  ################
  # Localization #
  ################

  # Keyboard and locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Timezone
  time.timeZone = "America/New_York";

  ############
  # Services #
  ############

  # SSH 
  services.openssh = {
    enable = true;

    # Public key authentication only
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  #########
  # Users #
  #########

  sops.secrets.port-password = {
    neededForUsers = true;
    sopsFile = ./secrets/secrets.yaml;
  };
  users.users.port = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    passwordFile = config.sops.secrets.port-password.path;
    openssh.authorizedKeys.keys = with config.metadata.hosts; [
      lagos.ssh_pubkey
      tugboat.ssh_pubkey
    ];
  };

  users.mutableUsers = false;

  security.pam.enableSSHAgentAuth = true;
  security.sudo.extraConfig = ''
    %wheel ALL= NOPASSWD:${pkgs.rsync}/bin/rsync
  '';

  ############
  # Packages #
  ############

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    htop
    tmux
  ];
}
