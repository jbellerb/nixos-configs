{ lib, fetchFromGitHub, buildNpmPackage, imagemagick }:

let
  version = "0.12.2";

in buildNpmPackage {
  pname = "feishin-web";
  inherit version;

  src = fetchFromGitHub {
    owner = "jeffvli";
    repo = "feishin";
    rev = "v${version}";
    sha256 = "sha256-2kWeUlOTAd1Usw/cLOARyLqxEzZRk27RuHjLwupnq80=";
  };

  patches = [ ./pwa-manifest.patch ];

  npmDepsHash = "sha256-KZsxKDAQ7UTnEemr6S9rqKtqPeTvqrhfxURSGTKkMMM=";

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" "--ignore-scripts" ];
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  configurePhase = ''
    ${imagemagick}/bin/magick -size 512x512 xc:#121212 -gravity center \
      \( media/feishin.png -geometry 410x410 \) -composite \
      assets/icons/pwa-icon-512.png
    ${imagemagick}/bin/magick -size 196x196 xc:#121212 -gravity center \
      \( media/feishin.png -geometry 156x156 \) -composite \
      assets/icons/pwa-icon-196.png
  '';

  npmBuildScript = "build:web";

  installPhase = ''
    mkdir -p $out/lib/feishin/
    mv release/app/dist/web $out/lib/feishin/dist
  '';

  meta = with lib; {
    homepage = "https://github.com/jeffvli/feishin";
    description = "A modern self-hosted music player.";
    license = licenses.gpl3Plus;
  };
}
