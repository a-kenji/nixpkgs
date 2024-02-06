{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  libxkbcommon,
  openssl,
  pkg-config,
  libglvnd,
  libGL,
  rustPlatform,
  makeWrapper,
  vulkan-loader,
  wayland,
  xorg,
}:
rustPlatform.buildRustPackage rec {
  pname = "halloy";
  version = "2023.5";

  src = fetchFromGitHub {
    owner = "squidowl";
    repo = "halloy";
    rev = "feat/new-iced";
    hash = "sha256-jFnIltlEVYqxOS71Y5sO0wUFCTQiWshCTyXlCu+AaeE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "iced-0.12.0" = "sha256-LtmAJDUMp42S4E+CjOM6Q7doAKOZkmJCN/49gsq3v/A=";
      "winit-0.29.10" = "sha256-YoXJEvEhMvk3pK5EbXceVFeJEJLL6KTjiw0kBJxgHIE=";
    };
  };

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    makeWrapper
  ];

  buildInputs =
    [
      libxkbcommon
      openssl
      vulkan-loader
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreGraphics
      darwin.apple_sdk.frameworks.Foundation
      darwin.apple_sdk.frameworks.Metal
      darwin.apple_sdk.frameworks.QuartzCore
      darwin.apple_sdk.frameworks.Security
    ]
    ++ lib.optionals stdenv.isLinux [
      wayland
      libglvnd
      libGL
    ];

  desktopItems = [
    (makeDesktopItem {
      name = "org.squidowl.halloy";
      desktopName = "Halloy";
      comment = "IRC client written in Rust";
      icon = "org.squidowl.halloy";
      exec = pname;
      terminal = false;
      mimeTypes = [
        "x-scheme-handler/irc"
        "x-scheme-handler/ircs"
      ];
      categories = [
        "Network"
        "IRCClient"
      ];
      keywords = [
        "IM"
        "Chat"
      ];
      startupWMClass = "org.squidowl.halloy";
    })
  ];

  postInstall = ''
      install -Dm644 assets/linux/org.squidowl.halloy.png $out/share/icons/hicolor/128x128/apps/org.squidowl.halloy.png
      wrapProgram "$out/bin/${pname}" \
    --prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        wayland
        libxkbcommon
        vulkan-loader
        libGL
      ]
    }

  '';

  meta = with lib; {
    description = "IRC application";
    homepage = "https://github.com/squidowl/halloy";
    changelog = "https://github.com/squidowl/halloy/blob/${version}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ fab ];
  };
}
