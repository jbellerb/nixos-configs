{ config, pkgs, ... }:

{
  services.miniflux = {
    enable = true;
    createDatabaseLocally = false;
    config.DATABASE_URL = "user=miniflux dbname=miniflux host=/run/postgresql";
    adminCredentialsFile = pkgs.writeText "miniflux-credentials" ''
      ADMIN_USERNAME=miniflux
      ADMIN_PASSWORD=miniflux
    '';
  };

  systemd.sockets.miniflux = {
    wantedBy = [ "sockets.target" ];

    listenStreams = [ "/run/miniflux.sock" ];
  };
  systemd.services.miniflux = {
    requires = [ "miniflux.socket" ];
    after = [
      "postgres.service"
      "miniflux-init.service"
    ];

    serviceConfig.NonBlocking = true;
  };

  systemd.services.miniflux-init = {
    wantedBy = [ "miniflux.service" ];
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];

    description = "Create the hstore PostgreSQL extention needed by Miniflux.";

    serviceConfig = {
      Type = "oneshot";
      User = config.services.postgresql.superUser;
    };
    script = ''
      ${pkgs.postgresql}/bin/psql miniflux -c \
        "CREATE EXTENSION IF NOT EXISTS hstore"
    '';
  };
}
