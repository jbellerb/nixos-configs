{
  inputs = {
    # pinning nixpkgs until https://github.com/NixOS/nixpkgs/issues/212086 is resolved
    nixpkgs.url = "github:nixos/nixpkgs?rev=62853fa9e0365f469b6c729862b48fd7ebad9c15";
    deploy-rs.url = "github:serokell/deploy-rs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, deploy-rs, fenix, home-manager, sops-nix }:
    let
      system = "x86_64-linux";

      metadata = import hosts/metadata.nix;

      defaultModules = [
        {
          imports = nixpkgs.lib.attrValues self.nixosModules;
          nixpkgs.pkgs = pkgs;
        }
        sops-nix.nixosModules.sops
      ];

      deployOverlay = final: prev: {
        deploy-rs = deploy-rs.packages."${system}".default;
      };
      deployLib = deploy-rs.lib."${system}";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          deployOverlay
          fenix.overlays.default
        ];
      };

    in {
      packages."${system}" = {
        inherit (pkgs.callPackage packages/pounce.nix {})
          pounce
          pounce-extra;
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
