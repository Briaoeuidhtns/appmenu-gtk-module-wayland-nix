{
  lib,
  stdenv,
  cmake,
  pkg-config,
  gtk3,
  libdbusmenu-gtk3,
  wayland,
  src,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appmenu-gtk-module-wayland";
  version = "24.02-unstable-${src.shortRev}";

  inherit src;
  patches = [
    ../patches/cmake-install.patch
    ../patches/public-dbusmenu-parser-api.patch
  ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ gtk3 libdbusmenu-gtk3 wayland ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ];

  passthru.gtkModule = "${finalAttrs.finalPackage}/lib/gtk-3.0/modules/libappmenu-gtk-module-wayland.so";

  meta = {
    description = "GTK 3 global menu module with Plasma Wayland support";
    homepage = "https://github.com/guiodic/appmenu-gtk-module-wayland";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
