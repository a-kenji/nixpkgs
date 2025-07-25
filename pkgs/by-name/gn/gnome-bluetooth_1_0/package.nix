{
  stdenv,
  lib,
  fetchurl,
  fetchpatch,
  gnome,
  adwaita-icon-theme,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  gtk3,
  gettext,
  glib,
  udev,
  itstool,
  libxml2,
  wrapGAppsHook3,
  libnotify,
  libcanberra-gtk3,
  gobject-introspection,
  gtk-doc,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  python3,
  gsettings-desktop-schemas,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-bluetooth";
  version = "3.34.5";

  # TODO: split out "lib"
  outputs = [
    "out"
    "dev"
    "devdoc"
    "man"
  ];

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-bluetooth/${lib.versions.majorMinor finalAttrs.version}/gnome-bluetooth-${finalAttrs.version}.tar.xz";
    hash = "sha256-bJSeUsi+zCBU2qzWBJAfZs5c9wml+pHEu3ysyTm1Pqk=";
  };

  patches = [
    # Fix build with meson 0.61.
    # sendto/meson.build:24:5: ERROR: Function does not take positional arguments.
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gnome-bluetooth/-/commit/755fd758f866d3a3f7ca482942beee749f13a91e.patch";
      hash = "sha256-N0MJ0pYO411o2CTNZHWmEoG2m5TGUjR6YW6HSXHTR/A=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    gettext
    itstool
    pkg-config
    libxml2
    wrapGAppsHook3
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    python3
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    gtk3
    udev
    libnotify
    libcanberra-gtk3
    adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  mesonFlags = [
    "-Dicon_update=false"
    "-Dgtk_doc=true"
  ];

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py
  '';

  strictDeps = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-bluetooth";
      attrPath = "gnome-bluetooth_1_0";
      freeze = true;
    };
  };

  meta = with lib; {
    homepage = "https://help.gnome.org/users/gnome-bluetooth/stable/index.html.en";
    description = "Application that let you manage Bluetooth in the GNOME destkop";
    mainProgram = "bluetooth-sendto";
    maintainers = [ ];
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
})
