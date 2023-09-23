{ config, lib, pkgs, flake, ... }:
with lib;
{
  config = mkIf config.workstation.enable {
    networking.networkmanager ={
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
        networkmanager-vpnc
      ];
      unmanaged = [ "interface-name:ve-*" ];
    };

    services.resolved.enable = true;
    services.avahi = {
      enable = true;
      nssmdns = true;
    };
  };
}
