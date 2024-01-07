{ pkgs, ... }:

{
  containers.jellyfin = {
    ephemeral = true;
    autoStart = true;
    config = { pkgs, ... }: {
      system.stateVersion = "23.11";
      networking.nameservers = [ "1.1.1.1" ];
      services.jellyfin = {
        enable = true;
        openFirewall = true;
        package = pkgs.jellyfin.overrideAttrs (old: {
          patches = old.patches ++ [
            (pkgs.writeText "playlists.patch" ''
              index 828ecb2c5..df68a7790 100644
              --- a/MediaBrowser.Controller/Playlists/Playlist.cs
              +++ b/MediaBrowser.Controller/Playlists/Playlist.cs
              @@ -24,11 +24,7 @@ namespace MediaBrowser.Controller.Playlists
                   {
                       public static readonly IReadOnlyList<string> SupportedExtensions = new[]
                       {
              -            ".m3u",
              -            ".m3u8",
              -            ".pls",
              -            ".wpl",
              -            ".zpl"
              +            ".none"
                       };

                       public Playlist()
            '')
          ];
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
  };
}
