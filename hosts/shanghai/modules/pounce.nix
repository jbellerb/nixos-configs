{ config, pkgs, lib, ... }:

{
  sops.secrets.shanghai-pounce-certfp-libera = { owner = "pounce"; };
  sops.secrets.shanghai-pounce-certfp-oftc = { owner = "pounce"; };
  sops.secrets.shanghai-pounce-webhook = { owner = "pounce"; };

  users.users.pounce.extraGroups = [ config.users.groups.keys.name ];

  services.pounce = {
    enable = true;
    host = "irc.shanghai.home";
    user = "pounce";
    openFirewall = true;

    networks.libera = {
      host = "irc.libera.chat";
      port = 6697;
      nick = "waves";
      client-cert = config.sops.secrets.shanghai-pounce-certfp-libera.path;
      sasl-external = true;
      join = "#openbsd,#nixos";
      away = "Currently disconnected from bouncer. A notification has been sent.";
    };

    networks.oftc = {
      host = "irc.oftc.net";
      port = 6697;
      nick = "waves";
      client-cert = config.sops.secrets.shanghai-pounce-certfp-oftc.path;
      join = "#vtluug,#vtluug-infra,#wuvt,#oftc";
      away = "Currently disconnected from bouncer. A notification has been sent.";
    };

    notify = let
      notify-script = network: ''
        NETWORK="${network}"
        WEBHOOK=$(cat "${config.sops.secrets.shanghai-pounce-webhook.path}")

        if [ -z "$NOTIFY_CHANNEL" ]; then
          TITLE="Private Message"
          CONTEXT="$NOTIFY_NICK"
        else
          TITLE="Highlight"
          CONTEXT="$NOTIFY_CHANNEL"
        fi

        ${pkgs.curl}/bin/curl \
          -H "Content-Type: application/json" \
          -d "{\"embeds\":[{\"title\":\"$TITLE | $NETWORK/$CONTEXT\",\"description\":\"$NOTIFY_TIME $NOTIFY_NICK: $NOTIFY_MESSAGE\"}]}" \
          $WEBHOOK
      '';
    in
    {
      libera.commands = notify-script "libera";
      oftc.commands = notify-script "oftc";
    };
  };
}
