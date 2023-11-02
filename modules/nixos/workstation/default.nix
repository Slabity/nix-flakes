{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./gaming.nix
    ./applications.nix
    ./networking.nix
    ./fonts.nix
  ];

  options.workstation = {
    enable = mkEnableOption "Workstation support";
    laptop.enable = mkEnableOption "Laptop support";
  };

  config = mkIf config.workstation.enable {
    services.dbus = {
      enable = true;
      packages = with pkgs; [ dconf ];
    };

    hardware = {
      bluetooth = {
        enable = true;
        package = pkgs.bluez;
      };
      keyboard.uhk.enable = true;
      inputDevices = {
        ps3Controller = true;
        wacomCintiq16Pro = true;
      };
    };

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };

    programs.hyprland = {
      enable = true;
      package = flake.hyprland.packages.${pkgs.system}.hyprland;
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.sessionVariables = {
      GTK_USE_PORTAL = "1";
      NIXOS_OZONE_WL = "1";
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.flatpak.enable = true;
    #services.input-remapper.enable = true;
    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
      alacritty # terminal

      xwayland # for legacy apps
      xorg.xrandr

      waybar # status bar
      mako # notification daemon
      kanshi # autorandr
      wdisplays
      waypipe

      # Screenshots
      grim
      slurp

      # GTK settings
      glib # for gsettings
      gnome.adwaita-icon-theme
      gtk-engine-murrine
      gtk_engines
      gsettings-desktop-schemas

      wl-clipboard
      wl-clipboard-x11

      wlr-randr
      wlrctl

      pavucontrol
      xdg-utils

      # Required because all polkit agents are stupid
      (pkgs.runCommand "polkit-sway" { preferLocalBuild = true; } ''
        mkdir -p $out/etc/xdg/autostart/
        sed -e 's/^OnlyShowIn=.*$/OnlyShowIn=sway;/' \
            -e 's/^AutostartCondition=.*$/AutostartCondition=sway;/' \
        ${pkgs.polkit_gnome}/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop > $out/etc/xdg/autostart/polkit-sway-authentication-agent-1.desktop
      '')
    ];

  };
}
