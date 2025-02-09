{ lib, pkgs, ... }:

{
  services.gonic = {
    enable = true;
    settings = {
      listen-addr = "127.0.0.1:4747";
      music-path = [ "/home/shares/jared/music" ];
      playlists-path = "/var/lib/gonic/playlists";
      podcast-path = "/dev/null";
      proxy-prefix = "/api";
    };
  };

  systemd.services.gonic.serviceConfig = {
    ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/gonic/playlists";
    BindPaths = lib.mkForce [ "/var/lib/gonic" ];
    ProtectHome = lib.mkForce "tmpfs";
  };
}
