{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "miniflux";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "miniflux" ];
  };
}
