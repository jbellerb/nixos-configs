{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-21.11-small"; };
    sops-nix = { url = "github:Mic92/sops-nix"; };
  };

  outputs = { self, nixpkgs, sops-nix }:
    let
      system = "x86_64-linux";

      defaultModules = [
        { 
          imports = nixpkgs.lib.attrValues self.nixosModules;
          nixpkgs.pkgs = pkgs;
        }
        sops-nix.nixosModules.sops
      ];

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
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

      nixosModules = { pounce = import modules/pounce.nix; };

      devShells."${system}".default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.sops
        ];
      };
    };
}
