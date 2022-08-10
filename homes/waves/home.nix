{ pkgs, ... }:

{
  home.username = "waves";
  home.homeDirectory = "/var/home/waves";

  home.stateVersion = "22.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.binutils
    pkgs.cachix
    pkgs.cargo
    pkgs.deploy-rs
    pkgs.gcc
    pkgs.htop
    pkgs.ripgrep
    pkgs.rustc
  ];

  programs.helix = {
    enable = false;
    settings = {
      theme = "monokai_pro_spectrum";
      editor = {
        mouse = false;
        true-color = true;
      };
    };
  };
}
