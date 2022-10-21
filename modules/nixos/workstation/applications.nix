{ config, lib, pkgs, flake, ... }:
with lib;
{
  config = mkIf config.workstation.enable {
    environment.systemPackages = with pkgs; [
      firefox-wayland

      libreoffice

      super-slicer

      krita
      gimp

      discord
      element-desktop

      obs-studio

      spotify
      mpv-with-scripts
    ];

    # For Virtual Camera support in OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  };
}
