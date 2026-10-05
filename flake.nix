{
  description = "Nix packaging for the appmenu GTK 3 Wayland module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    upstream = {
      url = "github:guiodic/appmenu-gtk-module-wayland/master";
      flake = false;
    };
  };

  outputs = { nixpkgs, upstream, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      nixosModule = import ./nix/module.nix { inherit upstream; };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          package = pkgs.callPackage ./nix/package.nix { src = upstream; };
        in
        {
          default = package;
          appmenu-gtk-module-wayland = package;
        });

      nixosModules = {
        default = nixosModule;
        appmenu-gtk-module-wayland = nixosModule;
      };
    };
}
