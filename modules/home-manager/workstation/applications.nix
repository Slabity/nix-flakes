{ config, lib, pkgs, flake, ... }:
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
      firefox

      super-slicer-latest

      feh
      krita
      gimp
      blender-hip

      discord-canary
      element-desktop

      transmission
      arduino
      audacity

      spotify
      mpv

      #helvum
      easyeffects
    ];
  };
}
