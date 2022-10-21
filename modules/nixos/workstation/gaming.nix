{ config, lib, pkgs, flake, ... }:
with lib;
{
  options.workstation.gaming = {
    enable = mkEnableOption "Gaming support";
  };

  config = mkIf config.workstation.gaming.enable {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    hardware.inputDevices.ps3Controller = true;

    environment.systemPackages = with pkgs; [
      steam-run
    ];

    environment.sessionVariables = rec {
      # For Steam to find additional Proton versions
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
