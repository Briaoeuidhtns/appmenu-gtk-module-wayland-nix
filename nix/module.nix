{ upstream }:
{ config, lib, pkgs, ... }:

let
  cfg = config.services.appmenu-gtk-module-wayland;
in
{
  options.services.appmenu-gtk-module-wayland = {
    enable = lib.mkEnableOption "the GTK 3 global menu module, including Plasma Wayland support";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { src = upstream; };
      defaultText = lib.literalExpression "pkgs.callPackage ./nix/package.nix { src = upstream; }";
      description = "Package providing lib/gtk-3.0/modules/libappmenu-gtk-module-wayland.so.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.sessionVariables = {
      GTK_MODULES = [ "${cfg.package}/lib/gtk-3.0/modules/libappmenu-gtk-module-wayland.so" ];
      UBUNTU_MENUPROXY = lib.mkDefault "1";
    };
  };
}
