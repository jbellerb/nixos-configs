{ config, lib, pkgs, ... }:

with lib;

{
  options.services.adlist = {
    enable = mkEnableOption "Refresh an ad-blocking hosts file each day";

    path = mkOption {
      type = types.path;
      description = "Location to place the ad-blocking hosts file.";
    };
  };

  config = mkIf config.services.adlist.enable {
    systemd.services.adlist-refresh = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];

      description = "Refresh the current ad-blocking hosts file.";

      serviceConfig.Type = "oneshot";

      script = ''
        ${pkgs.coreutils}/bin/mkdir \
          -p $(${pkgs.coreutils}/bin/dirname "${config.services.adlist.path}")
        ${pkgs.curl}/bin/curl \
          https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
          -o "${config.services.adlist.path}"
      '';
    };

    systemd.timers.adlist-refresh = {
      wantedBy = [ "timers.target" ];
      partOf = [ "adlist-refresh.service" ];

      timerConfig.OnCalendar = "daily";
    };
  };
}
