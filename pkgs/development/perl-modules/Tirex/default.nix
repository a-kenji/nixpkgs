{
  lib,
  buildPerlPackage,
  fetchFromGitHub,
  fetchpatch,
  GD,
  IPCShareLite,
  JSON,
  LWP,
  mapnik,
  boost,
  nix-update-script,
  pkg-config,
}:

buildPerlPackage rec {
  pname = "Tirex";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "tirex";
    tag = "v${version}";
    hash = "sha256-p2P19tifA/AvJatTzboyhtt7W1SwKJQzqpU4oDalfhU=";
  };

  patches = [
    # Support Mapnik >= v4.0.0 (`mapnik/box2d.hpp` -> `mapnik/geometry/box2d.hpp`)
    # https://github.com/openstreetmap/tirex/pull/54
    (fetchpatch {
      url = "https://github.com/openstreetmap/tirex/commit/5f131231c9c12e88793afba471b150ca8af8d587.patch";
      hash = "sha256-bnL1ZGy8ZNSZuCRbZn59qRVLg3TL0GjFYnhRKroeVO0=";
    })
    # Support Mapnik >= v4.0.0 (no more mapnik-config)
    ./use-pkg-config.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    GD
    IPCShareLite
    JSON
    LWP
    mapnik
    boost
  ]
  ++ mapnik.buildInputs;

  installPhase = ''
    install -m 755 -d $out/usr/libexec
    make install DESTDIR=$out INSTALLOPTS=""
    mv $out/$out/lib $out/$out/share $out
    rmdir $out/$out $out/nix/store $out/nix
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools for running a map tile server";
    homepage = "https://wiki.openstreetmap.org/wiki/Tirex";
    maintainers = with lib.maintainers; [ jglukasik ];
    license = with lib.licenses; [ gpl2Only ];
  };
}
