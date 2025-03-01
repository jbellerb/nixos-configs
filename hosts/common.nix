{ config, pkgs, ... }:

{
  # system.autoUpgrade.enable = true;

  system.stateVersion = "23.05";

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      log-lines = 20;

      # Force garbage collection of storage drops below 512MiB during build
      max-free = 1024 * 1024 * 1024;
      min-free = 512 * 1024 * 1024;

      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
    optimise.automatic = true;
  };
  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

  # Boot
  boot.initrd.systemd.enable = true;
  boot.loader = {
    grub.enable = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 8;
      editor = false;
    };

    efi.efiSysMountPoint = "/boot/efi";
  };

  # Keyboard and locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Timezone
  time.timeZone = "America/New_York";

  # Firewall
  networking.firewall.enable = true;

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
      lagos.sshPubkey
      tugboat.sshPubkey
    ];
  };

  services.userborn.enable = true;
  users.mutableUsers = false;

  security.pam.sshAgentAuth.enable = true;
  security.sudo.extraConfig = ''
    %wheel ALL= NOPASSWD:${pkgs.rsync}/bin/rsync
  '';

  # Disable NixOS Containers (to use systemd-nspawn instead)
  boot.enableContainers = false;

  # Packages
  system.disableInstallerTools = true;
  environment = {
    defaultPackages = [ ];
    systemPackages = with pkgs; [
      nixos-rebuild
      ghostty.terminfo
      wget
    ];
  };
  programs = {
    git.enable = true;
    htop.enable = true;
    nano.enable = false; # just don't like it, sorry...
    tmux.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };

    # Remove random perl bits
    less.lessopen = null;
    command-not-found.enable = false;
  };
  documentation.info.enable = false;
}
