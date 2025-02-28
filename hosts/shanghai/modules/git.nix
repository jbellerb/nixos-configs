{ config, pkgs, ... }:

let
  home = "/var/lib/git";
  uid = 1500;

in
{
  users.users.git = {
    isNormalUser = true;
    inherit home uid;
    openssh.authorizedKeys.keys = with config.metadata.hosts; [
      lagos.sshPubkey
      tugboat.sshPubkey
    ];
  };

  virtualization.nspawn.git = {
    config =
      { pkgs, ... }:
      {
        system.stateVersion = "24.11";

        users.users.git = {
          isNormalUser = true;
          inherit home uid;
          shell = "${pkgs.git}/bin/git-shell";
        };

        systemd.services.link-repos = {
          wantedBy = [ "multi-user.target" ];

          description = "Create symlinks to each git repo on root.";

          serviceConfig.Type = "oneshot";
          script = ''
            for repo in ${home}/*
            do
              ln -s "''$repo" "/''${repo##*/}.git"
            done
          '';
        };

        programs.git.enable = true;
      };

    bind = [ "${home}:${home}:idmap" ];
  };

  services.openssh.extraConfig = ''
    Match User git
      ForceCommand sudo systemd-run --machine=git --uid=${builtins.toString uid} --pipe --wait --quiet /run/current-system/sw/bin/git-shell -c "\''$SSH_ORIGINAL_COMMAND"
  '';

  security.sudo.extraRules = [
    {
      users = [ "git" ];
      runAs = "root";
      commands = [
        {
          command = ''
            /run/current-system/sw/bin/systemd-run --machine\=git --uid\=${builtins.toString uid} --pipe --wait --quiet /run/current-system/sw/bin/git-shell -c*
          '';
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
