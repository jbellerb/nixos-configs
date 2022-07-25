{ pkgs, ... }:

{
  containers.jellyfin = {
    ephemeral = true;
    autoStart = true;
    config = { pkgs, ... }: {
      networking.nameservers = [ "1.1.1.1" ];
      services.jellyfin = {
        enable = true;
        openFirewall = true;
        package = pkgs.jellyfin.overrideAttrs (old: {
          patches = [ (pkgs.writeText "playlists.patch" ''
            index 977b14c..6f9cd28 100644
            --- a/MediaBrowser.Controller/Playlists/Playlist.cs
            +++ b/MediaBrowser.Controller/Playlists/Playlist.cs
            @@ -23,11 +23,7 @@ namespace MediaBrowser.Controller.Playlists
                 {
                     public static string[] SupportedExtensions =
                         {
            -                ".m3u",
            -                ".m3u8",
            -                ".pls",
            -                ".wpl",
            -                ".zpl"
            +                ".none"
                         };

                     public Guid OwnerUserId { get; set; }
          '') ];
        });
      };
    };

    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath = "/var/lib/jellyfin/";
        isReadOnly = false;
      };
      "/mnt/music" = {
        hostPath = "/home/shares/jared/music/";
        isReadOnly = true;
      };
    };

    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    forwardPorts = [ { hostPort = 8096; } ];
  };
}
