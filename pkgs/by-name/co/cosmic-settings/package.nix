{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cmake,
  makeBinaryWrapper,
  cosmic-icons,
  cosmic-randr,
  just,
  pkg-config,
  expat,
  fontconfig,
  freetype,
  libinput,
  libxkbcommon,
  pipewire,
  pulseaudio,
  udev,
  util-linux,
  wayland,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-settings";
  version = "1.0.0-alpha.5.1";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "epoch-${version}";
    hash = "sha256-UOMU8Xy+El5yZk7yjM6k1Ge0144MAV4DB2e4hFFHFRg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-uof1KGlrZu5fzkeNRHwTUNHJLPzX7nglLkj1kFmsnwk=";

  postPatch = ''
    substituteInPlace justfile --replace '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [
    cmake
    just
    makeBinaryWrapper
    pkg-config
    rustPlatform.bindgenHook
    util-linux
  ];
  buildInputs = [
    expat
    fontconfig
    freetype
    libinput
    libxkbcommon
    pipewire
    pulseaudio
    udev
    wayland
  ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-settings"
  ];

  postInstall = ''
    wrapProgram "$out/bin/cosmic-settings" \
      --prefix PATH : ${lib.makeBinPath [ cosmic-randr ]} \
      --suffix XDG_DATA_DIRS : "$out/share:${cosmic-icons}/share"
  '';

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-settings";
    description = "Settings for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nyabinary ];
    platforms = platforms.linux;
    mainProgram = "cosmic-settings";
  };
}
