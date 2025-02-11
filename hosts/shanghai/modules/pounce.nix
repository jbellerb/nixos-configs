{ config, pkgs, ... }:

let
  away-msg = "Currently disconnected from bouncer. A notification has been sent.";

  notify-script = network: ''
    NETWORK="${network}"
    WEBHOOK=$(cat "${config.secrets.shanghai.pounce-webhook.path}")

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
  secrets.shanghai.pounce-webhook.owner = "pounce";
  services.pounce = {
    enable = true;
    host = "irc.shanghai.home";
    user = "pounce";
    openFirewall = true;

    networks = builtins.mapAttrs (name: config: {
      config = config // {
        away = away-msg;
      };
      notify.script = notify-script "name";
    }) config.secrets.shanghai.pounce-networks;
  };
}
