{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-21.11-small"; };
    deploy-rs = { url = "github:serokell/deploy-rs"; };
    sops-nix = { url = "github:Mic92/sops-nix?rev=85907ae7384477e447499f6e942d822d6f2998d8"; };
  };

  outputs = { self, nixpkgs, deploy-rs, sops-nix }:
    let
      system = "x86_64-linux";

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
    in
    {
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
          hostname = "127.0.0.1";
          profiles.system.path =
            deployLib.activate.nixos self.nixosConfigurations.suez;
        };
      };

      nixosModules = { pounce = import modules/pounce.nix; };

      devShells."${system}".default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.sops
          pkgs.deploy-rs
        ];
      };

      checks."${system}" = { } // (deployLib.deployChecks self.deploy);
    };
}
