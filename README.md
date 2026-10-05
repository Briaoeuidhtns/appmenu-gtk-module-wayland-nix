# appmenu-gtk-module-wayland-nix

Nix package and NixOS module for [appmenu-gtk-module-wayland](https://github.com/guiodic/appmenu-gtk-module-wayland).

## Flake input

```nix
inputs.appmenu = {
  url = "github:Briaoeuidhtns/appmenu-gtk-module-wayland-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## NixOS

Add to your system's `modules` list:

```nix
appmenu.nixosModules.default
{ services.appmenu-gtk-module-wayland.enable = true; }
```

Rebuild NixOS, then log out and back in.

## Per-application

Install a wrapped application instead of the original package:

```nix
let
  menuModule = appmenu.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
pkgs.symlinkJoin {
  name = "mousepad-with-appmenu";
  paths = [ pkgs.mousepad ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/mousepad \
      --prefix GTK_MODULES : "${menuModule.gtkModule}" \
      --set-default UBUNTU_MENUPROXY 1
  '';
}
```

## Build

```sh
nix build github:Briaoeuidhtns/appmenu-gtk-module-wayland-nix
```
