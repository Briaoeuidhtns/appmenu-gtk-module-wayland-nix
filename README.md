# appmenu-gtk-module-wayland Nix packaging

Standalone Nix packaging for [guiodic/appmenu-gtk-module-wayland](https://github.com/guiodic/appmenu-gtk-module-wayland).
No upstream C source is vendored here. The non-flake `upstream` input is fetched
from GitHub and pinned in `flake.lock`, currently at
`8963fc2c9439c2ea0544122c41c30c6ced538911`.

Two patches are applied only in the Nix build directory:

- `patches/cmake-install.patch`: install the module under `lib/gtk-3.0/modules`.
- `patches/public-dbusmenu-parser-api.patch`: use libdbusmenu's declared
  cached-item API instead of referencing the nonexistent `dbusmenu_gtk_parse_get_item` symbol.

## Build and update

```sh
nix build .
nix flake check --all-systems --no-build
```

The default package is also available as `packages.<system>.appmenu-gtk-module-wayland`.
Supported flake systems: `x86_64-linux` and `aarch64-linux`.
Installing the package alone does not activate the GTK module.

Update upstream independently of nixpkgs:

```sh
nix flake update upstream
nix build .
```

If upstream adopts a patch, remove it from `nix/package.nix` and delete the patch
file when updating the locked revision. Patches deliberately fail when their
context no longer applies; upstream updates need a build and runtime check.

## Enable for selected applications

Add this input to your system flake, replacing the path with the absolute path
to this packaging repository:

```nix
inputs.appmenu = {
  url = "path:/absolute/path/to/appmenu-gtk-module-wayland-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

With `pkgs` and the `appmenu` input in scope, install a wrapped application
instead of its unwrapped counterpart:

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

`gtkModule` is the package's absolute library path. `--prefix` preserves
existing GTK modules; `--set-default` respects an explicit `UBUNTU_MENUPROXY`,
including `0` to disable menu exporting. Close an application's existing
instance before testing a new launch environment.

For an ad-hoc Nushell launch from any directory, replace the packaging path
and `mousepad` with your repository path and GTK 3 executable:

```nu
let p = (nix build "path:/absolute/path/to/appmenu-gtk-module-wayland-nix" --no-link --print-out-paths | str trim); with-env { GTK_MODULES: ([$"($p)/lib/gtk-3.0/modules/libappmenu-gtk-module-wayland.so" ($env.GTK_MODULES? | default "")] | where {|s| $s != ""} | str join ":"), UBUNTU_MENUPROXY: "1" } { mousepad }
```

## Enable globally on NixOS

Using the same input, import the module in your system flake's outputs
(which receive `nixpkgs` and `appmenu`):

```nix
nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    appmenu.nixosModules.default
    { services.appmenu-gtk-module-wayland.enable = true; }
  ];
};
```

`nixosModules.appmenu-gtk-module-wayland` is also available. The module builds
against the host's `pkgs` using the same locked upstream source and patches.
It installs the package, adds its absolute library path to
`environment.sessionVariables.GTK_MODULES`, and defaults `UBUNTU_MENUPROXY`
to `1`. Other GTK modules can be added using list-valued definitions.
`services.appmenu-gtk-module-wayland.package` can override the package.
Rebuild NixOS, then log out and back in to activate the session environment.

## Limitations

A desktop global-menu consumer is required, such as Plasma's Global Menu
widget. This flake does not install or configure one. The module targets GTK 3,
not GTK 4, Qt, or sandboxed applications that cannot access the host's Nix store.
Applications forcing X11 can hide their menus without publishing them through
the Wayland protocol; select native Wayland where the application supports it.

Verification: x86_64 package build, GTK 3 loading and menu rendering under Xvfb,
wrapper environment preservation and explicit proxy override, and NixOS
activation/merge/package-override evaluation. Both flake systems evaluated;
aarch64 compilation and Plasma Wayland menu export were not exercised.
