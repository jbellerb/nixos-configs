{ pkgs, lib, ... }:

{
  home.username = "waves";
  home.homeDirectory = "/home/waves";

  home.stateVersion = "22.11";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.binutils
    pkgs.blackbox-terminal
    pkgs.cachix
    pkgs.cargo
    pkgs.deploy-rs
    pkgs.firefox
    pkgs.gcc
    pkgs.gnupg
    pkgs.ripgrep
    pkgs.rustc
    pkgs.sops
  ];

  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.cargo/bin" ];

  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting

      set --append fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d
    '';
  };
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.helix = {
    enable = false;
    settings = {
      theme = "everforest_dark";
      editor = {
        mouse = false;
        true-color = true;
      };
    };
  };

  programs.vim = {
    enable = true;
    plugins = [
      pkgs.vimPlugins.vim-sensible
      pkgs.vimPlugins.lightline-vim
      pkgs.vimPlugins.everforest
    ];
    settings = {
      background = "dark";

      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };
    extraConfig = ''
      if has('termguicolors')
        set termguicolors
      endif

      let g:everforest_background = 'hard'

      colorscheme everforest
      let g:lightline = {'colorscheme' : 'everforest'}
    '';
  };
  home.sessionVariables.EDITOR = "vim";

  dconf.settings."com/raggesilver/BlackBox" = {
    style-preference = lib.hm.gvariant.mkUint32 2;
    window-show-borders = false;
    theme-dark = "Everforest Dark Hard";
    theme-light = "Tomorrow";

    font = "VCTR Mono v0.10 12";
    terminal-cell-height = 1.1;
    terminal-padding = lib.hm.gvariant.mkTuple
      (map lib.hm.gvariant.mkUint32 [ 5 5 5 5 ]);

    use-custom-command = true;
    custom-shell-command = "/usr/bin/env fish";
  };
  home.file.".local/share/blackbox/schemes/everforest-dark-hard.json" = {
    text = ''
      {
          "name": "Everforest Dark Hard",
          "comment": "Adapted from https://github.com/sainnhe/everforest",
          "use-theme-colors": false,
          "foreground-color": "#d3c6aa",
          "background-color": "#2b3339",
          "palette": [
              "#445055",
              "#e67e80",
              "#a7c080",
              "#dbbc7f",
              "#7fbbb3",
              "#d699b6",
              "#83c092",
              "#d3c6aa",
              "#445055",
              "#e67e80",
              "#a7c080",
              "#dbbc7f",
              "#7fbbb3",
              "#d699b6",
              "#83c092",
              "#d3c6aa"
          ]
      }
    '';
  };
}
