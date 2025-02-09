{ config, pkgs, ... }:

let
  away-msg = "Currently disconnected from bouncer. A notification has been sent.";

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

    echo "sending notification to webhook..."
    ${pkgs.curl}/bin/curl \
      -H "Content-Type: application/json" \
      -d "{\"embeds\":[{\"title\":\"$TITLE | $NETWORK/$CONTEXT\",\"description\":\"$NOTIFY_TIME $NOTIFY_NICK: $NOTIFY_MESSAGE\"}]}" \
      $WEBHOOK
  '';

in
{
  users.users.pounce.extraGroups = [ config.users.groups.keys.name ];

  sops.secrets.shanghai-pounce-certfp-libera.owner = "pounce";
  sops.secrets.shanghai-pounce-certfp-oftc.owner = "pounce";
  sops.secrets.shanghai-pounce-webhook.owner = "pounce";
  services.pounce = {
    enable = true;
    host = "irc.shanghai.home";
    user = "pounce";
    openFirewall = true;

    networks = {
      libera = {
        config = {
          host = "irc.libera.chat";
          nick = "waves";
          client-cert = config.sops.secrets.shanghai-pounce-certfp-libera.path;
          sasl-external = true;
          join = "#openbsd,#nixos";
          away = away-msg;
          save = "/var/lib/pounce/buffer/libera";
        };
        notify.script = notify-script "libera";
      };

      oftc = {
        config = {
          host = "irc.oftc.net";
          nick = "waves";
          client-cert = config.sops.secrets.shanghai-pounce-certfp-oftc.path;
          join = "#vtluug,#vtluug-infra,#wuvt,#oftc";
          away = away-msg;
          save = "/var/lib/pounce/buffer/oftc";
        };
        notify.script = notify-script "oftc";
      };
    };
  };
}
