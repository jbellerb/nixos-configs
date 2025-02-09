{
  stdenv,
  fetchurl,
  pkg-config,
  libressl,
  ncurses,
}:

let
  pname = "catgirl";
  version = "9017c1512e3a9592086029868b5ca16ea3033066";

  src = fetchurl {
    url = "https://git.causal.agency/catgirl/snapshot/${pname}-${version}.tar.gz";
    sha256 = "sha256-ldUPq/oAHBqZ2CDC6UZd0vExnA+ws+8ccHUbLW58oxE=";
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libressl
    ncurses
  ];
  buildFlags = [ "all" ];

  # Forgive me for my sins...
  patches = [ ./no-tls.patch ];
}
