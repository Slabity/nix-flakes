{ config, lib, pkgs, flake, ... }:
with lib;
{
  config = mkIf config.workstation.enable {
    environment.systemPackages = with pkgs; [
      v4l-utils
    ];

    # For Virtual Camera support in OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  };
}
