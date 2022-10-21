{ config, lib, pkgs, flake, ... }:
with lib;
{
  config = mkIf config.workstation.enable {
    environment.systemPackages = with pkgs; [
      firefox-wayland

      libreoffice

      super-slicer

      feh
      krita
      gimp
      blender

      discord
      element-desktop

      transmission
      arduino
      audacity

      obs-studio

      spotify
      mpv
    ];

    # For Virtual Camera support in OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  };
}
