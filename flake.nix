{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    deploy-rs.url = "github:serokell/deploy-rs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, deploy-rs, fenix, home-manager, sops-nix }:
    let
      system = "x86_64-linux";

      metadata = import hosts/metadata.nix;

      deployOverlay = final: prev: {
        deploy-rs = deploy-rs.packages."${system}".default;
      };
      deployLib = deploy-rs.lib."${system}";

      defaultOverlays = [
        self.overlays.default
        deployOverlay
        fenix.overlays.default
      ];

      defaultModules = [
        {
          imports = nixpkgs.lib.attrValues self.nixosModules;
          system.stateVersion = "23.05";
          nixpkgs.overlays = defaultOverlays;
          inherit metadata;
        }
        sops-nix.nixosModules.sops
      ];

      pkgs = import nixpkgs {
        inherit system;
        overlays = defaultOverlays;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [ "Dirt-Samples" "discord" ];
      };

    in {
      packages."${system}" = {
        inherit (pkgs.callPackage packages/pounce.nix {})
          pounce
          pounce-extra;
        inherit (pkgs.callPackage packages/supercollider-quarks.nix {})
          vowel
          dirt-samples
          superdirt;
        vim-tidal = pkgs.callPackage packages/vim-tidal.nix {};
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
          profiles.system.path =
            deployLib.activate.nixos self.nixosConfigurations.lagos;
          profiles.waves = {
            user = "waves";
            path =
              deployLib.activate.home-manager self.homeConfigurations.waves;
          };
        };
        nodes.suez = {
          hostname = metadata.hosts.suez.wireguard.address.ipv6;
          profiles.system.path =
            deployLib.activate.nixos self.nixosConfigurations.suez;
        };
        nodes.shanghai = {
          hostname = metadata.hosts.shanghai.wireguard.address.ipv6;
          profiles.system.path =
            deployLib.activate.nixos self.nixosConfigurations.shanghai;
        };
      };

      nixosModules = {
        adlist = import modules/adlist.nix;
        metadata = import modules/metadata.nix;
        pounce = import modules/pounce.nix;
        wireguard = import modules/wireguard.nix;
      };

      devShells."${system}".default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.deploy-rs
          pkgs.sops
          pkgs.wireguard-tools
        ];
      };

      checks."${system}" = { } // (deployLib.deployChecks self.deploy);
    };
}
