{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.username = "waves";
  home.homeDirectory = "/home/waves";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.binutils
    (pkgs.callPackage ./packages/catgirl { })
    pkgs.cmake
    pkgs.gcc
    pkgs.git-filter-repo
    pkgs.libnotify
    pkgs.protobuf
    pkgs.ripgrep
    pkgs.toolbox

    # desktop
    pkgs.blackbox-terminal
    pkgs.discord
    pkgs.ghostty
    pkgs.newsflash

    # nix
    pkgs.cachix

    # rust
    (pkgs.fenix.combine [
      pkgs.fenix.default.toolchain
      pkgs.fenix.latest.rust-src
    ])
    pkgs.fenix.rust-analyzer
    pkgs.cargo-edit
    pkgs.cargo-expand

    # tidal
    pkgs.supercollider-with-sc3-plugins
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting
      set -g fish_key_bindings fish_vi_key_bindings
    '';
    plugins = [
      {
        name = "foreign-env";
        src = "${pkgs.fishPlugins.foreign-env}/share/fish";
      }
    ];
    functions = {
      fish_vcs_prompt = {
        description = "Print all vcs prompts";
        body = ''
          fish_jj_prompt $argv
          or fish_git_prompt $argv
          or fish_hg_prompt $argv
          or fish_fossil_prompt $argv
        '';
      };
      fish_jj_prompt = {
        description = "Prompt function for Jujutsu";
        body = ''
          if not command -sq jj; or not jj root &> /dev/null
              return 1
          end

          jj log --no-graph -r @ -T '
              surround(
                  " (",
                  ")",
                  separate(
                      " ",
                      coalesce(
                          if(
                              description.first_line().substr(0, 18).starts_with(description.first_line()),
                              description.first_line().substr(0, 18),
                              description.first_line().substr(0, 15) ++ "..."
                          ),
                          surround(
                              raw_escape_sequence("\e[33m"),
                              raw_escape_sequence("\e[0m"),
                              "(no description set)",
                          ),
                      ),
                      surround("(", ")", bookmarks.join(", ")),
                  ),
              )
          ' --ignore-working-copy --color always
        '';
      };
    };
  };
  programs.direnv = {
    enable = true;
    config = {
      hide_env_diff = true;
      load_dotenv = true;
    };
    nix-direnv.enable = true;
  };
  programs.nix-index.enable = true;

  programs.firefox.enable = true;

  programs.gpg.enable = true;
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-update ]);
  };
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
  systemd.user.sessionVariables = config.programs.password-store.settings;

  programs.helix = {
    enable = true;
    settings = {
      theme = "everforest_dark";
      editor = {
        mouse = false;
        true-color = true;
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "foss@jae.zone";
        name = "jae beller";
      };
      signing = {
        behavior = "own";
        backend = "gpg";
        key = "A76F1F7129E50AF7";
      };
      ui = {
        default-command = "status";
        editor = "hx";
        pager = "less -FRX";
      };
      aliases = {
        l = [ "log" ];
      };
      fix.tools = {
        nix = {
          command = [
            "${pkgs.nixfmt-rfc-style}/bin/nixfmt"
            "-f"
            "$path"
          ];
          patterns = [ "glob:'**/*.nix'" ];
        };
      };
    };
  };

  programs.vim = {
    enable = true;
    plugins = [
      pkgs.vimPlugins.vim-sensible
      pkgs.vimPlugins.lightline-vim
      pkgs.vimPlugins.everforest

      pkgs.vim-tidal

      pkgs.vimPlugins.goyo-vim
      pkgs.vimPlugins.limelight-vim
    ];
    settings = {
      background = "dark";
      number = true;

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

      let g:tidal_ghci = '${pkgs.haskellPackages.ghcWithPackages (pkgs: [ pkgs.tidal ])}/bin/ghci'
      let maplocalleader=","

      let g:goyo_linenr = 1
      autocmd! User GoyoEnter Limelight
      autocmd! User GoyoEnter set vb
      autocmd! User GoyoLeave Limelight!
      autocmd! User GoyoLeave set novb
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
    terminal-padding = lib.hm.gvariant.mkTuple (
      map lib.hm.gvariant.mkUint32 [
        5
        5
        5
        5
      ]
    );

    use-custom-command = true;
    custom-shell-command = "/usr/bin/env fish";
  };
  home.file."${config.xdg.dataHome}/blackbox/schemes/everforest-dark-hard.json" = {
    text = ''
      {
          "name": "Everforest Dark Hard",
          "comment": "Adapted from https://github.com/sainnhe/everforest",
          "use-theme-colors": false,
          "foreground-color": "#d3c6aa",
          "background-color": "#272e33",
          "palette": [
              "#414b50",
              "#e67e80",
              "#a7c080",
              "#dbbc7f",
              "#7fbbb3",
              "#d699b6",
              "#83c092",
              "#d3c6aa",
              "#414b50",
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

  xdg.configFile."SuperCollider/sclang_conf.yaml" = {
    text = lib.generators.toYAML { } ({
      includePaths = lib.concatMap (quark: [ "${quark}/quark" ]) [ pkgs.superdirt ];
    });
  };
}
