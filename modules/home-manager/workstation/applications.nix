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
  };
}
