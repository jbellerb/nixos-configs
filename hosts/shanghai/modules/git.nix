{ config, ... }:

{
  users.users.git = {
    isNormalUser = true;
    useDefaultShell = true;
    home = "/home/git";
    uid = 1500;
    openssh.authorizedKeys.keys = with config.metadata.hosts; [
      lagos.ssh_pubkey
      tugboat.ssh_pubkey
    ];
  };
}
