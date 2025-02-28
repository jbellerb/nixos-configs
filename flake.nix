{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      metadata = import hosts/metadata.nix;

      # Fetch with getFlake instead of inputs so packages and modules can still
      # be used, even when the consumer doesn't have access to the secrets
      # repository. Nix's lazy evaluation ensures this only gets pulled when
      # it's needed for building nixosConfigurations.
      secretsRepo = "git+ssh://git@shanghai.home/nixos-secrets";
      secretsRev = "8f6807a90ecf1421fb8958afce09269c18facd2c";
      secrets = builtins.getFlake "${secretsRepo}?rev=${secretsRev}";

      deployOverlay = final: prev: {
        deploy-rs = inputs.deploy-rs.packages."${system}".default;
      };
      deployLib = inputs.deploy-rs.lib."${system}";

      defaultOverlays = [
        self.overlays.default
        deployOverlay
        inputs.fenix.overlays.default
        inputs.ghostty.overlays.default
      ];

      defaultModules = [
        {
          imports = nixpkgs.lib.attrValues self.nixosModules;
          nixpkgs.overlays = defaultOverlays;
          inherit metadata;
        }
        secrets.nixosModules.secrets
      ];

      pkgs = import nixpkgs {
        inherit system;
        overlays = defaultOverlays;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "Dirt-Samples"
            "discord"
          ];
      };

      treefmt = inputs.treefmt-nix.lib.evalModule pkgs (
        { pkgs, ... }:
        {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          settings.global.excludes = [
            ".envrc"
            "LICENSE"
            "README.md"
          ];
        }
      );

    in
    {
      packages."${system}" = {
        apprise-api = pkgs.callPackage packages/apprise-api.nix { };
        feishin-web = pkgs.callPackage packages/feishin-web/default.nix { };
        inherit (pkgs.callPackage packages/pounce.nix { })
          pounce
          pounce-extra
          ;
        inherit (pkgs.callPackage packages/supercollider-quarks.nix { })
          vowel
          dirt-samples
          superdirt
          ;
        vim-tidal = pkgs.callPackage packages/vim-tidal.nix { };
      };

      overlays.default = final: prev: { } // self.packages."${system}";

      nixosConfigurations = {
        lagos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [ hosts/lagos/configuration.nix ];
        };
        shanghai = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [ hosts/shanghai/configuration.nix ];
        };
        suez = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [ hosts/suez/configuration.nix ];
        };
      };

      homeConfigurations = {
        waves = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ homes/waves/home.nix ];
        };
      };

      deploy = {
        sshUser = "port";
        user = "root";

        sshOpts = [ "-A" ];

        nodes.lagos = {
          hostname = metadata.hosts.lagos.wireguard.address.ipv6;
          profiles.system.path = deployLib.activate.nixos self.nixosConfigurations.lagos;
          profiles.waves = {
            user = "waves";
            path = deployLib.activate.home-manager self.homeConfigurations.waves;
          };
        };
        nodes.suez = {
          hostname = metadata.hosts.suez.wireguard.address.ipv6;
          profiles.system.path = deployLib.activate.nixos self.nixosConfigurations.suez;
        };
        nodes.shanghai = {
          hostname = metadata.hosts.shanghai.wireguard.address.ipv6;
          profiles.system.path = deployLib.activate.nixos self.nixosConfigurations.shanghai;
        };
      };

      nixosModules = {
        adlist = import modules/adlist.nix;
        apprise = import modules/apprise.nix;
        metadata = import modules/metadata.nix;
        nspawn = import modules/nspawn.nix;
        pounce = import modules/pounce.nix;
        secrets = import modules/secrets.nix;
        wireguard = import modules/wireguard.nix;
      };

      devShells."${system}".default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.deploy-rs ];
      };

      formatter."${system}" = treefmt.config.build.wrapper;

      checks."${system}" = {
        formatting = treefmt.config.build.check self;
      } // (deployLib.deployChecks self.deploy);
    };
}
