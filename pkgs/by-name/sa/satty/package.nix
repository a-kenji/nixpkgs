{ lib
, stdenv
, fetchFromGitHub
, cargo
, pkg-config
, rustPlatform
, rustc
, wrapGAppsHook4
, cairo
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, pango
}:

stdenv.mkDerivation rec {
  pname = "satty";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "gabm";
    repo = "Satty";
    rev = "v${version}";
    hash = "sha256-rR24RFM9chq2f2C/aIk6WXIfTUU36Qnm9jOLiRiUnyE=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  PREFIX = "$out";

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
  ];

  meta = with lib; {
    description = "Satty - Modern Screenshot Annotation. A Screenshot Annotation Tool inspired by Swappy and Flameshot";
    homepage = "https://github.com/gabm/Satty.git";
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    mainProgram = "satty";
    platforms = platforms.all;
  };
}
