{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.workstation.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-multi-rtmp
        obs-gstreamer
      ];
    };

    home.packages = with pkgs; [
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

      spotify
      mpv
    ];
  };
}
