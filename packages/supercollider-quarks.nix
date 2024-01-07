{ lib, stdenvNoCC, fetchFromGitHub }:

let
  buildSuperColliderQuark = {
    pname,
    version,
    src,
    runtimeDeps ? [],
    meta ? null
  }:
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

      installPhase = ''
        mkdir -p "$out/quark/${pname}"
        cp -r ./* "$out/quark/${pname}"

        if [ -n "${toString (runtimeDeps != [])}" ]
        then
          for dep in ${lib.concatMapStringsSep " " toString runtimeDeps}
          do
            if [ -d "$dep/quark" ]; then
              ln -s $(readlink -f "$dep/quark"/*) "$out/quark"
            else
              echo "Dependency \"$dep\" is not a Quark" && false
            fi
          done
        fi
      '';
    };

in rec {
  vowel = buildSuperColliderQuark {
    pname = "Vowel";
    version = "ab59caa870201ecf2604b3efdd2196e21a8b5446";

    src = fetchFromGitHub {
      owner = "supercollider-quarks";
      repo = "Vowel";
      rev = "ab59caa870201ecf2604b3efdd2196e21a8b5446";
      hash = "sha256-zfF6cvAGDNYWYsE8dOIo38b+dIymd17Pexg0HiPFbxM=";
    };

    meta = with lib; {
      homepage = "https://github.com/supercollider-quarks/Vowel";
      description = "Convenience Class for Vowel Creation";
      license = licenses.lgpl21Only;
      platforms = platforms.all;
    };
  };

  dirt-samples = buildSuperColliderQuark {
    pname = "Dirt-Samples";
    version = "92f2145e661b397e62ca0ff3965819e7c7db0dad";

    src = fetchFromGitHub {
      owner = "tidalcycles";
      repo = "Dirt-Samples";
      rev = "92f2145e661b397e62ca0ff3965819e7c7db0dad";
      hash = "sha256-Zl2bi9QofcrhU63eMtg+R6lhV9ExQS/0XNTJ+oq65Uo=";
    };

    meta = with lib; {
      homepage = "https://github.com/tidalcycles/Dirt-Samples";
      description = "Set of samples used in Dirt";
      license = licenses.unfree;
      platforms = platforms.all;
    };
  };

  superdirt = buildSuperColliderQuark {
    pname = "SuperDirt";
    version = "1.7.3";

    src = fetchFromGitHub {
      owner = "musikinformatik";
      repo = "SuperDirt";
      rev = "v1.7.3";
      hash = "sha256-FFBJBlUY6jttEEkn3qldS8z2qoncSyDITUy+x/6l5F8=";
    };

    runtimeDeps = [ vowel dirt-samples ];

    meta = with lib; {
      homepage = "https://github.com/musikinformatik/SuperDirt";
      description = "Tidal Audio Engine";
      license = licenses.gpl2Plus;
      platforms = platforms.all;
    };
  };
}
