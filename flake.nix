{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.05-small"; };
    deploy-rs = { url = "github:serokell/deploy-rs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; };
  };

  outputs = { self, nixpkgs, deploy-rs, sops-nix }:
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
        overlays = [ self.overlays.default deployOverlay ];
      };

    in {
      packages."${system}" = {
        inherit (pkgs.callPackage packages/pounce.nix {})
          pounce
          pounce-extra;
      };

      overlays.default = final: prev: { } // self.packages."${system}";

      nixosConfigurations = {
        shanghai = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [
            hosts/shanghai/configuration.nix
          ];
        };
        suez = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [
            hosts/suez/configuration.nix
          ];
        };
      };

      deploy = {
        sshUser = "port";
        user = "root";

        sshOpts = [ "-A" ];

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
