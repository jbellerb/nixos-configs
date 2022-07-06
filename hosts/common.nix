{ config, lib, pkgs, ... }:

with lib;

{
  system.stateVersion = "21.11";
  # system.autoUpgrade.enable = true;

  nix = {
    package = pkgs.nix_2_4;
    extraOptions = "experimental-features = nix-command flakes";

    binaryCaches = [ "https://nix-community.cachix.org" ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    gc.automatic = true;
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
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEPu4d15Bpe4aismAmXTrndwdXImNV8vsoLqhvwg754kGku8Fi8duamaTXdDftVG8cbS+1rA3u+tR+aFUqxaBtMO9jgwPlEAMMyMUj+jcrjGRlHe+XJgDVWFFdPbxHR7b9gYSahzzCHz1h5vAc3WTLUDIdz7EkG2LYERgR3FVHZ6v5Q8CSwWd741DiezkDGbhu8TBVrekKtLH6XC49J6mU03nJUe0oKk5mTbqYZFcn4IeFX98G068aYAQMuJQ9sjGYp5OlqPp1A3jHL755sjrrnBef2pJl0cd5wwgyUX0IxUdpjF8SR5RFZG1YNJDgGY4cCHCQvzw+lx0cLJHMDK5R lagos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI2qx9/prfNZ+SzatkRncojXfDlUNrp7Iw7myA7qpK2 lagos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuIgouw4tmR/OhZchYUyWKGTJL0AMTLXEOxRwqvHm41 tugboat"
    ];
  };

  # Enable passwd
  users.mutableUsers = true;

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
