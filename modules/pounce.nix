{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pounce;

  defaultUser = "pounce";

  settingsFormat = {
    type = types.attrsOf (types.nullOr
      (types.oneOf [ types.bool types.int types.str ]));
    generate = name: value:
      let
        mkKeyValue = k: v:
          if true == v then k
          else if false == v then "#${k}"
          else lib.generators.mkKeyValueDefault {} " = " k v;
        mkKeyValueList = values:
          lib.generators.toKeyValue { inherit mkKeyValue; } values;
      in pkgs.writeText name (mkKeyValueList value);
  };

in {
  options.services.pounce = {
    enable = mkEnableOption "Pounce IRC bouncer with the Calico dispatcher";

    user = mkOption {
      type = types.str;
      default = defaultUser;
      description = ''
        User account under which Pounce runs. If not specified, a default user
        will be created.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/run/pounce";
      description = ''
        Directory where each Pounce instance's UNIX-domain socket is stored for
        Calico to route to.
      '';
    };

    certDir = mkOption {
      type = types.str;
      default = "/var/lib/pounce/certs";
      example = "/etc/letsencrypt/live";
      description = ''
        Directory where each Pounce instance's TLS certificates and private
        keys are stored. Each instance should have a folder in the certbot
        format: a <literal>fullchain.pem</literal> and
        <literal>privkey.pem</literal> in a folder with the full domain name of
        the instance (ex: <literal>libera.example.org/</literal>). Self-signed
        certificates will be generated in this folder if
        <option>services.pounce.generateCerts</option> is true.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "localhost";
      example = "example.org";
      description = ''
        Base domain name for Calico to listen at. Each instance will be at a
        subdomain of this.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 6697;
      description = "Port for Calico to listen on.";
    };

    generateCerts = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Generate a self-signed TLS certificate in the certificate directory.
        If you would like to use <command>certbot</command> instead, generate
        certificates for each instance like this:
        <literal>certbot certonly -d libera.example.org</literal>.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in the firewall for Calico.";
    };

    timeout = mkOption {
      type = types.ints.positive;
      default = 1000;
      description = ''
        Timeout parameter (in milliseconds) for Calico to close a connection
        if no <literal>ClientHello</literal> message is sent.
      '';
    };

    networks = mkOption {
      type = types.attrsOf settingsFormat.type;
      default = {};
      example = {
        libera = {
          host = "irc.libera.chat";
          port = 6697;
          sasl-plain = "testname:password";
          join = "#nixos,#nixos-dev";
        };
      };
      description = ''
        Attribute set of Pounce configurations. For information on the Pounce
        configuration format, see the
        <link xlink:href="https://git.causal.agency/pounce/about/pounce.1">pounce(1)</link>
        manual page.
      '';
    };

    notify = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          insecure = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Disable certificate validation for connecting to the Pounce
              instance. Must be <literal>true</literal> if using a
              self-signed certificate with Pounce.
            '';
          };
          client-cert = mkOption {
            type = types.str;
            default = "";
            description = ''
              Client certificate to use if Pounce is configured to require
              certificate authentication. If the relevant private key is stored
              in a separate file, load it with
              <option>services.pounce.notify.<name>.client-priv</option>.
            '';
          };
          client-priv = mkOption {
            type = types.str;
            default = "";
            description = ''
              Private key to use if Pounce is configured to require certificate
              authentication. If the certificate provided in
              <option>services.pounce.notify.<name>.client-cert</option> has
              an embedded private key, this option can be left empty.
            '';
          };
          user = mkOption {
            type = types.str;
            default = "pounce-notify";
            description = "Username to present to Pounce when connecting.";
          };
          commands = mkOption {
            type = types.str;
            default = "";
            example = ''
              # Pushover example

              if [ -z "$NOTIFY_CHANNEL" ]; then
                TITLE="Private Message"
                CONTEXT="$NOTIFY_NICK"
              else
                TITLE="Mention"
                CONTEXT="$NOTIFY_CHANNEL"
              fi

              ${pkgs.curl}/bin/curl \
                -X POST \
                --form-string token="API_TOKEN" \
                --form-string user="USER_KEY" \
                --form-string title="(libera/$CONTEXT) $TITLE" \
                --form-string timestamp="$NOTIFY_TIME" \
                --form-string message="$NOTIFY_NICK: $NOTIFY_MESSAGE" \
                https://api.pushover.net/1/messages.json
            '';
            description = ''
              Series of commands to run when a private message or a mention
              occurs. See
              <link xlink:href="https://git.causal.agency/pounce/about/extra/notify/pounce-notify.1">pounce-notify(1)</link>
              for a list of environment variables containing information about
              the notification event.
            '';
          };
          script = mkOption {
            type = types.str;
            default = "";
            example = "/var/lib/pounce/notify.sh";
            description = ''
              Script to run when a private message or a mention occurs.
              Overrides
              <option>services.pounce.notify.<name>.commands</option>. See
              <link xlink:href="https://git.causal.agency/pounce/about/extra/notify/pounce-notify.1">pounce-notify(1)</link>
              for a list of environment variables containing information about
              the notification event.
            '';
          };
        };
      });
      default = {};
      description = ''
        Attribute set of notification clients to spawn. Each field must match a
        network defined in <option>services.pounce.networks</option>.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.user} -" ];
    systemd.services = mkMerge [
      {
        calico = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          description = "Calico dispatcher for Pounce IRC bouncer.";

          serviceConfig = {
            User = cfg.user;
            Group = cfg.user;
            ExecStart = ''
              ${pkgs.pounce}/bin/calico \
                -H ${cfg.host} -P ${toString cfg.port} \
                -t ${toString cfg.timeout} ${cfg.dataDir}
            '';
            Restart = "on-failure";
          };
        };
      }

      (mapAttrs' (name: value: nameValuePair "pounce-${name}" {
        wantedBy = [ "calico.service" ];
        after = [ "network.target" ];
        before = [ "calico.service" ];

        description = "Pounce IRC bouncer for the ${name} network.";

        serviceConfig = {
          User = cfg.user;
          Group = cfg.user;
          ExecStart = ''
            ${pkgs.pounce}/bin/pounce \
              -C ${cfg.certDir}/${name}.${cfg.host}/fullchain.pem \
              -K ${cfg.certDir}/${name}.${cfg.host}/privkey.pem \
              -U ${cfg.dataDir} -H ${name}.${cfg.host} \
              ${settingsFormat.generate "${name}.cfg" value}
          '';
          Restart = "on-failure";
        };
        preStart = ''
          mkdir -p ${cfg.certDir}/${name}.${cfg.host}

          if ${boolToString cfg.generateCerts}; then
            if [ ! -f ${cfg.certDir}/${name}.${cfg.host}/fullchain.pem ] || \
               [ ! -f ${cfg.certDir}/${name}.${cfg.host}/privkey.pem ]; then
              ${pkgs.libressl}/bin/openssl req -x509 -newkey rsa:4096 \
                -out ${cfg.certDir}/${name}.${cfg.host}/fullchain.pem \
                -keyout ${cfg.certDir}/${name}.${cfg.host}/privkey.pem \
                -nodes -sha256 -days 36500 -subj "/CN=${name}.${cfg.host}"
            fi
          fi
        '';
      }) cfg.networks)

      (mapAttrs' (name: value:
        assert (assertMsg (cfg.networks ? "${name}")
          "Cannot listen for notifications on ${name}: network does not exist.");
        nameValuePair "pounce-notify-${name}" {
          wantedBy = [ "multi-user.target" ];
          requires = [ "calico.service" "pounce-${name}.service" ];
          after = [ "calico.service" "pounce-${name}.service" ];

          description = "Pounce notification client for the ${name} network.";

          serviceConfig = {
            User = cfg.user;
            Group = cfg.user;
            Environment = "SHELL=${pkgs.bash}/bin/bash";
            ExecStart = ''
              ${pkgs.pounce-extra}/bin/pounce-notify \
                ${if value.insecure then "-!" else ""} \
                ${if value.client-cert != "" then "-c ${value.client-cert}" else ""} \
                ${if value.client-priv != "" then "-k ${value.client-priv}" else ""} \
                -p ${toString cfg.port} -u ${value.user} \
                ${if cfg.networks.${name} ? local-pass
                  then "-w cfg.networks.${name}.local-pass" else ""} \
                ${name}.${cfg.host} \
                ${if value.script != "" then value.script else
                  pkgs.writeShellScript "pounce-notify-${name}-commands" value.commands}
            '';
            Restart = "on-failure";

            # pounce will refuse all connections before it's connected to the
            # IRC network, but there's no easy way for systemd to know when
            # that's happened. The best I've come up with is starting
            # pounce-notify anyways and retrying with a fairly long delay.
            # This value works for me, hopefully it works for you too.
            RestartSec = "15s";
          };
        })
      cfg.notify)
    ];

    users = optionalAttrs (cfg.user == defaultUser) {
      users.${defaultUser} = {
        group = defaultUser;
        isSystemUser = true;
      };

      groups.${defaultUser} = { };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    environment.systemPackages = [ pkgs.pounce ];
  };

  # meta = {
  #   doc = ./pounce.xml;
  #   maintainers = [ lib.maintainers.jbellerb ];
  # };
}
