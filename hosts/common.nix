{ config, lib, pkgs, ... }:

with lib;

{
  # system.autoUpgrade.enable = true;

  nix = {
    settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [ "root" "@wheel" ];
    };

    extraOptions = "experimental-features = nix-command flakes";

    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
    optimise.automatic = true;
  };

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
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
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
    hashedPasswordFile = config.sops.secrets.port-password.path;
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

  programs.nano.enable = false;
}
