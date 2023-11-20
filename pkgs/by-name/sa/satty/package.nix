{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, wrapGAppsHook4
, cairo
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, pango
}:

rustPlatform.buildRustPackage rec {
  pname = "satty";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "gabm";
    repo = "Satty";
    rev = "v${version}";
    hash = "sha256-x2ljheG7ZqaeiPersC/e8Er2jvk5TJs65Y3N1GjTiNU=";
  };

  cargoLock =  {
    lockFile = ./Cargo.lock;
  };

  patches = [ ./fix_lock.patch ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

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
