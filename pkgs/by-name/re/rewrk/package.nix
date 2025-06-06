{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rewrk";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "lnx-search";
    repo = "rewrk";
    rev = version;
    hash = "sha256-Bqr5kmIIx+12hW4jpINcv0GBJBbMAkd4di/hZSXlT18=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "More modern http framework benchmarker supporting HTTP/1 and HTTP/2 benchmarks";
    homepage = "https://github.com/lnx-search/rewrk";
    changelog = "https://github.com/lnx-search/rewrk/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ figsoda ];
    mainProgram = "rewrk";
  };
}
