{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.apprise;

  hardeningFlags = {
    CapabilityBoundingSet = [ "" ];
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RemoveIPC = true;
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
    ];
    RestrictNamespaces = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
  };

  staticWrapper = pkgs.writeTextFile {
    name = "apprise-whitenoise-wrapper";
    text = ''
      from whitenoise import WhiteNoise
      from core import wsgi

      application = WhiteNoise(
          wsgi.application,
          root="${cfg.package}/opt/apprise/apprise_api/static",
          prefix="s/",
      )
    '';
    destination = "/apprise_api/wsgi.py";
  };

  extraPaths = concatStringsSep "," (
    with pkgs.python3Packages;
    [
      "${whitenoise}/${python.sitePackages}"
      staticWrapper
    ]
  );

in
{
  options.services.apprise = {
    enable = mkEnableOption "the Apprise API server";

    package = mkPackageOption pkgs "apprise-api" { };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        User account under which Apprise runs. If not specified, the server will
        run with a dynamically allocated user. When running as a dynamic user,
        all directories except for {file}`/tmp/` and {file}`/run/apprise/` will
        be read-only.
      '';
    };

    group = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Group account under which Apprise runs. This option is ignored if
        {option}`services.apprise.user` is not set.
      '';
    };

    listenAddr = mkOption {
      type = types.str;
      default = "localhost";
      description = "Address for the server to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for the server to listen on.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in the firewall for Apprise.";
    };

    serveStatic = mkOption {
      type = types.bool;
      default = true;
      description = "Serve static files internally with WhiteNoise.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf (types.nullOr types.str);
        options = {
          ALLOWED_HOSTS = mkOption {
            type = types.listOf types.str;
            default = [ "*" ];
            example = [ "apprise.example.org" ];
            description = "A list of hosts that the API may serve under.";
            apply = concatStringsSep ",";
          };
          APPRISE_ATTACH_DIR = mkOption {
            type = types.path;
            default = "/run/apprise/attach";
            example = "/var/lib/apprise/attach";
            description = ''
              The directory for storing uploaded file attachments.
            '';
          };
          APPRISE_ATTACH_SIZE = mkOption {
            type = types.numbers.nonnegative;
            default = 200;
            example = 0;
            description = ''
              The maximum size (in MB) for file attachments.
            '';
          };
          APPRISE_CONFIG_LOCK = mkOption {
            type = types.bool;
            default = true;
            example = false;
            description = ''
              Lock the server configuration as read-only when interacted with
              through the web interface.
            '';
            apply = bool: if bool then "yes" else "no";
          };
          APPRISE_STATEFUL_MODE = mkOption {
            type = types.enum [
              "hash"
              "simple"
              "disabled"
            ];
            default = "disabled";
            example = "simple";
            description = ''
              How (or whether at all) to store configuration changes made while
              the server is actively running.
            '';
          };
          APPRISE_WORKER_COUNT = mkOption {
            type = types.ints.positive;
            default = 1;
            description = ''
              The number of workers to run. Unlike the upstream Docker
              container, this module defaults to only 1 worker.
            '';
          };
          APPRISE_WORKER_TIMEOUT = mkOption {
            type = types.ints.positive;
            default = 300;
            description = ''
              The number of seconds a worker has to send all pending
              notifications before timing out.
            '';
          };
          BASE_URL = mkOption {
            type = types.str;
            default = "";
            example = "/api";
            description = ''
              URL prefix in use if Apprise is served behind a reverse proxy.
            '';
          };
        };
      };
      default = { };
      description = ''
        Environment variables to be passed to the API server. See [Apprise's
        README](https://github.com/caronc/apprise-api?tab=readme-ov-file#environment-variables)
        for a complete list of all possible variables. By default, Apprise will
        be set up in stateless mode.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.apprise = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      description = "API server for the Apprise Notification Library.";

      serviceConfig = {
        User = mkIf (cfg.user != null) cfg.user;
        Group = mkIf (cfg.group != null) cfg.group;
        DynamicUser = cfg.user == null;

        RuntimeDirectory =
          with cfg.settings;
          mkIf (hasPrefix "/run/" APPRISE_ATTACH_DIR) (removePrefix "/run/" APPRISE_ATTACH_DIR);

        EnvironmentFile = pkgs.writeText "apprise-env" (
          generators.toKeyValue { } (
            {
              PYTHONPATH = pkgs.python3Packages.makePythonPath cfg.package.dependencies;
            }
            // filterAttrs (_: value: value != null) cfg.settings
          )
        );
        ExecStart = ''
          ${pkgs.python3Packages.gunicorn}/bin/gunicorn \
            -b ${cfg.listenAddr}:${builtins.toString cfg.port} \
            -w ${builtins.toString cfg.settings.APPRISE_WORKER_COUNT} \
            -t ${builtins.toString cfg.settings.APPRISE_WORKER_TIMEOUT} \
            -k gevent --max-requests 1000 --max-requests-jitter 50 \
            --access-logfile - --error-logfile - --log-level warn \
            --pythonpath ${cfg.package}/opt/apprise/apprise_api${
              if cfg.serveStatic then ",${extraPaths} apprise_api.wsgi" else " core.wsgi"
            }
        '';

        Restart = "on-failure";
      } // hardeningFlags;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
