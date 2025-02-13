{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.virtualization.nspawn;

in
{
  options.virtualization.nspawn = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        let
          name = config._module.args.name;
        in
        {
          options = {
            config = mkOption {
              type = lib.mkOptionType {
                name = "NixOS config";
                # Largely copied from
                # <nixpkgs>/nixos/modules/virtualisation/nixos-containers.nix.
                merge =
                  loc: defs:
                  (import "${toString pkgs.path}/nixos/lib/eval-config.nix" {
                    modules = [
                      {
                        nixpkgs = { inherit (pkgs.stdenv) hostPlatform; };
                        boot.isContainer = true;

                        networking = {
                          hostName = name;
                          useDHCP = false;
                          useHostResolvConf = false;
                        };
                      }
                    ] ++ (builtins.map (def: def.value) defs);
                    prefix = [
                      "containers"
                      name
                    ];
                    system = null;
                  }).config;
              };
              description = "NixOS config for the container image.";
            };
            autoStart = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to automatically start the container at boot or not.
              '';
            };
            veth = mkEnableOption ''
              a virtual ethernet connection between the host and the container.
            '';
            bind = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                List of bind mounts to make. See {manpage}`systemd-nspawn(1)` for
                the specific format expected.
              '';
            };
            bindReadOnly = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                List of read only bind mounts to make. See
                {manpage}`systemd-nspawn(1)` for the specific format expected.
              '';
            };
          };
        }
      )
    );
    default = { };
    description = ''
      A set of NixOS configurations to run as systemd-nspawn containers.
    '';
  };

  config = {
    systemd.nspawn = builtins.mapAttrs (_: container: {
      execConfig = {
        Ephemeral = true;
        Boot = false;
        Parameters = "${container.config.system.build.toplevel}/init";
        PrivateUsers = "pick";
      };
      filesConfig = {
        Bind = container.bind;
        BindReadOnly = [ "/nix/store" ] ++ container.bindReadOnly;
      };
      networkConfig.VirtualEthernet = container.veth; # true implies Private=yes
    }) cfg;

    # Register auto-started containers to be wanted by machines.target
    systemd.targets.machines.wants = lib.mapAttrsToList (name: _: "systemd-nspawn@${name}.service") (
      lib.filterAttrs (_: container: container.autoStart) cfg
    );

    # Create root directories for each container
    systemd.tmpfiles.settings."10-nspawn-roots" =
      (lib.concatMapAttrs (name: container: {
        "/var/lib/machines/${name}/etc/os-release"."C+".argument =
          "${container.config.system.build.toplevel}/etc/os-release";
      }) cfg)
      // {
        "/var/lib/machines".d.mode = "700";
      };
  };
}
