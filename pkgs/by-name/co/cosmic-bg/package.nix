{ lib, rustPlatform, fetchFromGitHub, makeBinaryWrapper, pkg-config
, libinput, libglvnd, libxkbcommon, mesa, seatd, udev, wayland, xorg
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-bg";
  version = "unstable-2023-10-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "6a6fe4e387e46c2e159df56a9768220a6269ccf4";
    sha256 = "sha256-fdRFndhwISmbTqmXfekFqh+Wrtdjg3vSZut4IAQUBbA=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
       "cosmic-config-0.1.0" =  "sha256-vM5iIr71zg8OWShuoyQI+pV9C5dPXnvkfEVYAg0XAH4=";
       "smithay-client-toolkit-0.17.0" = "sha256-XXfXRXeEm2LCLTfyd74PYuLmTtLu50pcXKld/6H4juA=";
    };
  };

  separateDebugInfo = true;

  nativeBuildInputs = [ makeBinaryWrapper pkg-config ];
  buildInputs = [ libglvnd libinput libxkbcommon mesa seatd udev wayland ];

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client, which is always dlopen()ed except by the
  # obscure winit backend.
  RUSTFLAGS = map (a: "-C link-arg=${a}") [
    "-Wl,--push-state,--no-as-needed"
    "-lEGL"
    "-lwayland-client"
    "-Wl,--pop-state"
  ];

  # These libraries are only used by the X11 backend, which will not
  # be the common case, so just make them available, don't link them.
  postInstall = ''
    wrapProgram $out/bin/cosmic-bg \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
      ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-comp";
    description = "Compositor for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ qyliss ];
    platforms = platforms.linux;
  };
}
