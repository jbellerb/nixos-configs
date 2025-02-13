{ config, pkgs, ... }:

{
  virtualization.nspawn.jellyfin = {
    veth = true;
    config =
      { pkgs, ... }:
      {
        system.stateVersion = "24.11";

        systemd.network = {
          enable = true;
          networks."10-host0" = {
            name = "host0";
            matchConfig = {
              Kind = "veth";
              Virtualization = "container";
            };
            address = [ "10.233.1.2/24" ];
            gateway = [ "10.233.1.1" ];
            dns = [ "1.1.1.1" ];
          };
        };

        services.jellyfin = {
          enable = true;
          openFirewall = true;
          user = "root"; # mapped to the jellyfin user through rootidmap
          group = "root";
          package = pkgs.jellyfin.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [
              (pkgs.writeText "playlists.patch" ''
                index 45aefacf6..569a82fb9 100644
                --- a/MediaBrowser.Controller/Playlists/Playlist.cs
                +++ b/MediaBrowser.Controller/Playlists/Playlist.cs
                @@ -23,11 +23,7 @@ namespace MediaBrowser.Controller.Playlists
                     {
                         public static readonly IReadOnlyList<string> SupportedExtensions =
                         [
                -            ".m3u",
                -            ".m3u8",
                -            ".pls",
                -            ".wpl",
                -            ".zpl"
                +            ".none"
                         ];

                         public Playlist()
              '')
            ];
          });
        };
      };

    bind = [ "/var/lib/jellyfin:/var/lib/jellyfin:rootidmap" ];
    bindReadOnly = [ "/home/shares/jared/music:/mnt/music" ];
  };

  users = {
    users.jellyfin = {
      group = "jellyfin";
      isSystemUser = true;
    };
    groups.jellyfin = { };
  };
  systemd.tmpfiles.settings."20-jellyfin-state"."/var/lib/jellyfin".d = {
    user = "jellyfin";
    group = "jellyfin";
  };

  systemd.network.networks."20-ve-jellyfin" = {
    name = "ve-jellyfin";
    matchConfig.Kind = "veth";
    address = [ "10.233.1.1/24" ];
    networkConfig.IPMasquerade = "both";
  };
}
