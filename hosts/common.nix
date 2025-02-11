{ config, pkgs, ... }:

{
  # system.autoUpgrade.enable = true;

  nix = {
    settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    extraOptions = "experimental-features = nix-command flakes";

    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
    optimise.automatic = true;
  };

  # Keyboard and locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Timezone
  time.timeZone = "America/New_York";

  # SSH
  services.openssh = {
    enable = true;

    # Public key authentication only
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Users
  secrets.common.port-password.neededForUsers = true;
  users.users.port = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.secrets.common.port-password.path;
    openssh.authorizedKeys.keys = with config.metadata.hosts; [
      lagos.ssh_pubkey
      tugboat.ssh_pubkey
    ];
  };

  users.mutableUsers = false;

  security.pam.sshAgentAuth.enable = true;
  security.sudo.extraConfig = ''
    %wheel ALL= NOPASSWD:${pkgs.rsync}/bin/rsync
  '';

  # Packages
  environment.systemPackages = with pkgs; [ wget ];
  programs = {
    git.enable = true;
    htop.enable = true;
    nano.enable = false; # just don't like it, sorry...
    tmux.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
