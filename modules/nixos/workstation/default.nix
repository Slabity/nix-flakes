{ config, lib, pkgs, flake, ... }:
with lib;
{
  options.workstation = {
    enable = mkEnableOption "Workstation support";
    laptop.enable = mkEnableOption "Laptop support";
  };

  config = mkIf config.workstation.enable {
    services.dbus = {
      enable = true;
      packages = with pkgs; [ dconf ];
    };

    networking.networkmanager ={
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
      unmanaged = [ "interface-name:ve-*" ];
    };

    services.resolved.enable = true;
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    fonts = {
      enableDefaultFonts = true;
      fonts = with pkgs; [
        corefonts source-code-pro source-sans-pro source-serif-pro
        font-awesome terminus_font powerline-fonts google-fonts inconsolata noto-fonts
        noto-fonts-cjk unifont ubuntu_font_family nerdfonts
      ];
      fontconfig = {
        enable = true;
        defaultFonts.monospace = [
          "Terminess Powerline"
          "TerminessTTF Nerd Font Mono"
        ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        hinting.enable = true;
        antialias = true;
      };
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    programs.steam.enable = true;

    hardware = {
      bluetooth = {
        enable = true;
        hsphfpd.enable = true;
        package = pkgs.bluez;
      };

      steam-hardware.enable = true;
      keyboard.uhk.enable = true;
    };

    sound.enable = true;
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      media-session.enable = false;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.sessionVariables = {
      GTK_USE_PORTAL = "1";
    };

    environment.systemPackages = with pkgs; [
      alacritty # terminal

      swaylock # lockscreen
      swayidle

      xwayland # for legacy apps

      waybar # status bar
      mako # notification daemon
      kanshi # autorandr
      wdisplays

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

      firefox-wayland
      pavucontrol
      xdg-utils
    ];

    hardware.inputDevices = {
      ps3Controller = true;
      wacomCintiq16Pro = true;
    };
  };
}
