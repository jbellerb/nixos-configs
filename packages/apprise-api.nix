{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  version = "1.1.8";

in
python3Packages.buildPythonApplication {
  pname = "apprise-api";
  inherit version;

  src = fetchFromGitHub {
    owner = "caronc";
    repo = "apprise-api";
    rev = "v${version}";
    sha256 = "sha256-Gr1KF1kAltTkyyoRPpZ3KlUzxgKHG4V/od65yAT8YEk=";
  };

  format = "other";
  dependencies = with python3Packages; [
    apprise
    cryptography
    django
    gevent
    gntp
    paho-mqtt
    requests
  ];

  installPhase = ''
    mkdir -p $out/opt/apprise
    cp -r . $out/opt/apprise
  '';

  meta = {
    description = "A lightweight REST framework that wraps the Apprise Notification Library";
    homepage = "https://github.com/caronc/apprise-api";
    license = lib.licenses.mit;
  };
}
