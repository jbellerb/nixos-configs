{ config, lib, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings =
      {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "Samba %v on %L";
          "netbios name" = "shanghai";
          "security type" = "user";
          # "use sendfile" = "yes";
          # "max protocol" = "smb2";
          "hosts allow" = "192.168.1.0/24 10.131.0.0/24 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
      }
      // lib.listToAttrs (
        map (
          n:
          lib.nameValuePair n {
            path = "/home/shares/${n}";
            browseable = "no";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0700";
            "directory mask" = "0700";
            "valid users" = "${n}";
          }
        ) config.secrets.shanghai.samba-shares
      );
  };

  users.groups = {
    smbusers = {
      gid = 1000;
    };
  };

  users.extraUsers = lib.listToAttrs (
    lib.imap1 (
      i: n:
      lib.nameValuePair n {
        isNormalUser = true;
        home = "/home/shares/${n}";
        group = "smbusers";
        uid = 2000 + i;
      }
    ) config.secrets.shanghai.samba-shares
  );
}
