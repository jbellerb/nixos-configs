{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
  ];

  services.nginx = rec {
    enable = true;
    user = "nginx";
    group = "nginx";
    virtualHosts = {
      "jellyfin.shanghai.home" = {
        locations."/" = {
          proxyPass = "http://10.233.1.2:8096";
        };
      };
      "subsonic.shanghai.home" = {
        locations = {
          "/" = {
            root = "${pkgs.feishin-web}/lib/feishin/dist/";
          };
          "/api/" = {
            proxyPass = "http://${builtins.head config.services.gonic.settings.listen-addr}/";
            extraConfig = "proxy_set_header X-Forwarded-Host $host;";
          };
          "=/settings.js" =
            let
              settings = pkgs.writeTextFile {
                name = "feishin-web-settings-script";
                text = ''
                  "use strict";

                  window.SERVER_URL = "http://subsonic.shanghai.home/api";
                  window.SERVER_NAME = "shanghai";
                  window.SERVER_TYPE = "subsonic";
                  window.SERVER_LOCK = true;
                '';
                destination = "/settings.js";
              };
            in
            {
              root = "${settings}/";
            };
        };
      };
      "miniflux.shanghai.home" = {
        locations."/" = {
          proxyPass = "http://unix:/run/miniflux.sock";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
      "*.shanghai.home" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8081";
          extraConfig = ''
            proxy_set_header Host $host;
          '';
        };
      };

      # bridged HTTPS version
      "subsonic.shanghai.bridge.raindropdrop.top" = {
        forceSSL = true;
        useACMEHost = "shanghai.bridge.raindropdrop.top";
        locations = virtualHosts."subsonic.shanghai.home".locations // {
          "=/settings.js" =
            let
              settings = pkgs.writeTextFile {
                name = "feishin-web-settings-script-ssl";
                text = ''
                  "use strict";

                  window.SERVER_URL = "https://subsonic.shanghai.bridge.raindropdrop.top/api";
                  window.SERVER_NAME = "shanghai";
                  window.SERVER_TYPE = "subsonic";
                  window.SERVER_LOCK = true;
                '';
                destination = "/settings.js";
              };
            in
            {
              root = "${settings}/";
            };
        };
      };
      "miniflux.shanghai.bridge.raindropdrop.top" = {
        forceSSL = true;
        useACMEHost = "shanghai.bridge.raindropdrop.top";
        locations = virtualHosts."miniflux.shanghai.home".locations;
      };
    };
  };

  secrets.shanghai.cloudflare-dns-api-token.owner = "nginx";
  security.acme = {
    acceptTerms = true;
    defaults.email = "e+letsencrypt@jae.zone";
    certs."shanghai.bridge.raindropdrop.top" = {
      domain = "*.shanghai.bridge.raindropdrop.top";
      group = "nginx";
      dnsProvider = "cloudflare";
      environmentFile = config.secrets.shanghai.cloudflare-dns-api-token.path;
    };
  };
}
