{ lib, ... }:

with lib;

{
  options.metadata = mkOption {
    type = types.submodule {
      options = {
        hosts = mkOption {
          type = types.attrsOf types.anything; # TODO: proper types
          description = ''
            Relevant hosts. Mostly used for configuring Wireguard.
          '';
        };
      };
    };
    description = ''
      Attribute set of various constants avaliable through
      <option>config.metadata</option>.
    '';
  };
}
