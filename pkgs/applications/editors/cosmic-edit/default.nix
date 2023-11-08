{ lib
, stdenv
, fetchFromGitHub
, rust
, rustPlatform
, cmake
, makeBinaryWrapper
, cosmic-icons
, just
, pkg-config
, libxkbcommon
, glib
, gtk3
, libinput
, fontconfig
, freetype
, wayland
, expat
, udev
, which
, lld
, util-linuxMinimal
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-edit";
  version = "unstable-2023-11-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-edit";
    rev = "c66a28320a5274d62d68a6d90567bcf4d3e9666c";
    hash = "sha256-QmIF2QAKx/dImKLy2qXJHIBs+/JhbHXE4FTqR2FClrA=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "accesskit-0.11.0" = "sha256-xVhe6adUb8VmwIKKjHxwCwOo5Y1p3Or3ylcJJdLDrrE=";
      "cosmic-config-0.1.0" = "sha256-IyxAnQCR3btqBeQf0ZRozGXCz+xFiiT/oyaUUX+rjQY=";
      "cosmic-text-0.10.0" = "sha256-8YqRog4/QBijOvWzkMjKHm859WxkrOUOc9Ubze6Ypyo";
      "modit-0.1.0" = "sha256-skTUarsaBLWl0LSxzJQ2MdFGvcKPAbazRdss4Q+PeT8=";
      "sctk-adwaita-0.5.4" = "sha256-yK0F2w/0nxyKrSiHZbx7+aPNY2vlFs7s8nu/COp2KqQ=";
      "smithay-client-toolkit-0.16.1" = "sha256-z7EZThbh7YmKzAACv181zaEZmWxTrMkFRzP0nfsHK6c=";
      "softbuffer-0.2.0" = "sha256-VD2GmxC58z7Qfu/L+sfENE+T8L40mvUKKSfgLmCTmjY=";
      "taffy-0.3.11" = "sha256-0hXOEj6IjSW8e1t+rvxBFX6V9XRum3QO2Des1XlHJEw=";
      "winit-0.28.6" = "sha256-FhW6d2XnXCGJUMoT9EMQew9/OPXiehy/JraeCiVd76M=";
    };
  };

  postPatch = ''
    substituteInPlace justfile --replace '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [ cmake just pkg-config which lld util-linuxMinimal makeBinaryWrapper ];
  buildInputs = [ libxkbcommon libinput fontconfig freetype wayland expat udev glib gtk3 ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${rust.lib.toRustTargetSpecShort stdenv.hostPlatform}/release/cosmic-edit"
  ];

  postInstall = ''
    wrapProgram "$out/bin/${pname}" \
      --suffix XDG_DATA_DIRS : "${cosmic-icons}/share"
  '';

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-edit";
    description = "Text Editor for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ahoneybun ];
    platforms = platforms.linux;
  };
}
