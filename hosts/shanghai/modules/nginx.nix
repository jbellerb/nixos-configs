{
  networking.firewall.allowedTCPPorts = [ 80 8080 ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "jellyfin.shanghai.home" = {
        locations."/" = {
          proxyPass = "http://10.233.1.2:8096";
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
    };
  };
}
