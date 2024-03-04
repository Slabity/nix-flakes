{ config, lib, pkgs, flake, ... }:
let
  exec-terminal = pkgs.writeTextFile {
    name = "exec-terminal";
    destination = "/bin/exec-terminal";
    executable = true;

    text = ''
      #!/bin/sh

      if [ -z $\{@+zsh} ]
      then
          cmd=$\{SHELL-zsh}
      else
          cmd=$@
      fi

      if [ -t 0 ]
      then
          exec $cmd
      fi

      exec alacritty -e $cmd
    '';
  };
in
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

    programs.firefox = {
      enable = true;
    };

    programs.mpv = {
      enable = true;
    };

    programs.nnn = {
      enable = true;
    };

    home.packages = with pkgs; [
      feh
      krita
      gimp

      discord-canary
      element-desktop

      transmission
      arduino
      audacity

      spotify
      mpv

      helvum
      easyeffects

      imagemagick

      exec-terminal
    ];

    xdg.desktopEntries = {
      nnn = {
        name = "filebrowser";
        genericName = "File Browser";
        exec = "${exec-terminal}/bin/exec-terminal nnn %U";
        terminal = false;
        mimeType = [ "inode/directory" ];
      };
    };

    xdg.mimeApps.enable = true;
  };
}
