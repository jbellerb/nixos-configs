{ lib, stdenv, fetchzip, symlinkJoin, curl, libressl, pkg-config, sqlite }:

let
  version = "3.0";

  src = fetchzip {
    url = "https://git.causal.agency/pounce/snapshot/pounce-${version}.tar.gz";
    sha256 = "17vmbfr7ika6kmq9jqa3rpd4cr71arapav7hlmggnj7a9yw5b9mg";
  };

  common = { pname, sourceRoot, buildInputs, meta ? null }:
    stdenv.mkDerivation {
      inherit pname version src sourceRoot buildInputs;

      nativeBuildInputs = [ pkg-config ];

      buildFlags = [ "all" ];

      makeFlags = [
        "PREFIX=$(out)"
      ];

      inherit meta;
    };

  notify = common {
    pname = "pounce-notify";
    sourceRoot = "source/extra/notify";
    buildInputs = [ libressl ];
  };

  palaver = common {
    pname = "pounce-palaver";
    sourceRoot = "source/extra/palaver";
    buildInputs = [ curl.dev libressl sqlite.dev ];
  };

in {
  pounce = common {
    pname = "pounce";

    sourceRoot = "source";

    buildInputs = [ libressl ];

    meta = with lib; {
      homepage = "https://git.causal.agency/pounce/about/";
      description = "Simple, multi-client, TLS-only IRC bouncer";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ edef ];
    };
  };

  pounce-extra = symlinkJoin {
    name = "pounce-extra-${version}";

    paths = [ notify palaver ];

    meta = with lib; {
      homepage = "https://git.causal.agency/pounce/about/";
      description = "Special-purpose clients for extending the Pounce IRC bouncer";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ jbellerb ];
    };
  };
}
