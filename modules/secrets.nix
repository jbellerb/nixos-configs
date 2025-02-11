{ config, lib, ... }:

with lib;

let
  secretOption = parent: {
    type = types.nullOr (
      types.submodule (submod: {
        options = {
          id = mkOption {
            type = types.str;
            default = "${parent}-${submod.config._module.args.name}";
            description = "Unique name for the decrypted secret file.";
          };
          mode = mkOption {
            type = types.str;
            default = "0400";
            description = "Permissions mode of the decrypted secret as octal digits.";
          };
          owner = mkOption {
            type = types.str;
            default = "root";
            description = "User of the decrypted secret file.";
          };
          group = mkOption {
            type = types.str;
            default = config.users."${submod.config.owner}".group or "root";
            defaultText = lib.literalExpression ''
              users.''${config.owner}.group or "root"
            '';
            description = "Group the decrypted secret file.";
          };
          neededForUsers = mkOption {
            type = types.bool;
            default = false;
            description = "Decrypt the secret before NixOS creates users.";
          };
          path = mkOption {
            type = types.str;
            default =
              if submod.config.neededForUsers then
                "/run/secrets-for-users/${submod.config.id}"
              else
                "/run/secrets/${submod.config.id}";
            description = "Path where the decrypted secret is installed.";
          };
        };
      })
    );
    default = null;
  };

  pounceSettingsType = types.attrsOf (
    types.nullOr (
      types.oneOf [
        types.bool
        types.int
        types.str
      ]
    )
  );

in
{
  options.secrets = mkOption {
    type = types.submodule {
      options = {
        common = mkOption {
          type = types.submodule {
            options = {
              port-password = mkOption (secretOption "common");
            };
          };
          default = { };
          description = "Secrets shared between all hosts.";
        };
        suez = mkOption {
          type = types.submodule {
            options = {
              wireguard-private = mkOption (secretOption "suez");
              "Khome.+013+34119.key" = mkOption (secretOption "suez");
              "Khome.+013+34119.private" = mkOption (secretOption "suez");
            };
          };
          default = { };
        };
        shanghai = mkOption {
          type = types.submodule {
            options = {
              wireguard-private = mkOption (secretOption "shanghai");
              cloudflare-dns-api-token = mkOption (secretOption "shanghai");
              pounce-webhook = mkOption (secretOption "shanghai");
              pounce-networks = mkOption {
                type = types.attrsOf (pounceSettingsType);
                description = "Configs for each instance of pounce to run.";
              };
              samba-shares = mkOption {
                type = types.listOf types.str;
                description = "Names of each Samba share to provision.";
              };
            };
          };
          default = { };
        };
        lagos = mkOption {
          type = types.submodule {
            options = {
              waves-password = mkOption (secretOption "lagos");
              "wg0.nmconnection" = mkOption (secretOption "lagos");
            };
          };
          default = { };
        };
        wireguard = mkOption {
          type = types.submodule {
            options = {
              suez-shanghai-psk = mkOption (secretOption "wireguard");
              suez-tugboat-psk = mkOption (secretOption "wireguard");
              suez-lagos-psk = mkOption (secretOption "wireguard");
              suez-paris-psk = mkOption (secretOption "wireguard");
              suez-carrier-1-psk = mkOption (secretOption "wireguard");
              suez-carrier-2-psk = mkOption (secretOption "wireguard");
              suez-carrier-3-psk = mkOption (secretOption "wireguard");
              suez-carrier-4-psk = mkOption (secretOption "wireguard");
              suez-carrier-5-psk = mkOption (secretOption "wireguard");
            };
          };
          default = { };
        };
      };
    };
    description = "Attribute set of secrets exposed through a private flake.";
  };
}
