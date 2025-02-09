{
  lib,
  fetchFromGitHub,
  vimUtils,
}:

let
  version = "e440fe5bdfe07f805e21e6872099685d38e8b761";

in
vimUtils.buildVimPlugin {
  pname = "vim-tidal";
  inherit version;

  src = fetchFromGitHub {
    owner = "tidalcycles";
    repo = "vim-tidal";
    rev = version;
    sha256 = "sha256-8gyk17YLeKpLpz3LRtxiwbpsIbZka9bb63nK5/9IUoA=";
  };

  meta = with lib; {
    homepage = "https://github.com/tidalcycles/vim-tidal";
    description = "Vim plugin for TidalCycles";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
