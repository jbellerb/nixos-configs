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
        overlays = [ self.overlay ];
      };
    in
    {
      packages."${system}" = {
        inherit (pkgs.callPackage packages/pounce.nix {})
          pounce
          pounce-extra;
      };

      overlay = final: prev: { } // self.packages."${system}";

      nixosConfigurations = {
        shanghai = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [
            hosts/shanghai/configuration.nix
          ];
        };
      };

      nixosModules = { pounce = modules/pounce.nix; };
    };
}
