{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;

  users.users.port.extraGroups = [ "docker" ];
}
