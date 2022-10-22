{ config, lib, pkgs, flake, ... }:
with lib;
let
  colors = {
    primary.background = "#151017";
    primary.foreground = "#F5E1FF";
    normal.black = "#3B2B42";
    normal.red = "#CC396A";
    normal.green = "#00919E";
    normal.yellow = "#CC4759";
    normal.blue = "#7B42CC";
    normal.magenta = "#B72AD9";
    normal.cyan = "#1C7ACC";
    normal.white = "#9883A3";
    bright.black = "#5A4b62";
    bright.red = "#F288AB";
    bright.green = "#6CBDC5";
    bright.yellow = "#EB7181";
    bright.blue = "#B295DB";
    bright.magenta = "#D899E8";
    bright.cyan = "#9AC1E4";
    bright.white = "#EAD8FF";
  };

  # Below scripts taken from `https://nixos.wiki/wiki/Sway`

  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in
{
  imports = [
    ./applications.nix
  ];

  options = {
    workstation.enable = mkEnableOption "Workstation support";
  };

  config = mkIf config.workstation.enable {
    fonts.fontconfig.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      package = null;
      config = {
        modifier = "Mod4";
        bars = [];
        colors = {
          focused = {
            border = colors.normal.blue;
            background = colors.primary.background;
            text = colors.primary.foreground;
            indicator = colors.normal.blue;
            childBorder = colors.normal.blue;
          };
          focusedInactive = {
            border = colors.bright.blue;
            background = colors.primary.background;
            text = colors.primary.foreground;
            indicator = colors.bright.blue;
            childBorder = colors.bright.blue;
          };
          unfocused = {
            border = colors.normal.white;
            background = colors.primary.background;
            text = colors.primary.foreground;
            indicator = colors.normal.white;
            childBorder = colors.normal.white;
          };
          urgent = {
            border = colors.normal.magenta;
            background = colors.primary.background;
            text = colors.primary.foreground;
            indicator = colors.normal.magenta;
            childBorder = colors.normal.magenta;
          };
          placeholder = {
            border = colors.normal.black;
            background = colors.primary.background;
            text = colors.primary.foreground;
            indicator = colors.normal.black;
            childBorder = colors.normal.black;
          };
        };
        output = {
          "\*" = {
            background = "${colors.primary.background} solid_color";
          };
        };
        floating = {
          modifier = "Mod4";
          titlebar = false;
          criteria = [
            { app_id = "pavucontrol"; }
          ];
        };
        gaps = {
          inner = 2;
        };
        keybindings = let modifier = "Mod4"; in {
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" = "exec --no-startup-id ${pkgs.wofi}/bin/wofi --show run";
          "${modifier}+k" = "focus up";
          "${modifier}+j" = "focus down";
          "${modifier}+h" = "focus left";
          "${modifier}+l" = "focus right";
          "${modifier}+a" = "focus parent";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+v" = "split v";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";
        };
        startup = [
          { command = "${dbus-sway-environment}/bin/dbus-sway-environment"; }
          { command = "${configure-gtk}/bin/configure-gtk"; }
        ];
      };
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
      settings = [
        {
          layer = "top";
          position = "top";
          height = 1;

          modules-left = [
            "sway/workspaces"
            "custom/right-slant-end"
          ];

          modules-center = [
            "custom/left-slant-end"
            "clock#1"
            "custom/left-slant-divide"
            "clock#2"
            "custom/right-slant-divide"
            "clock#3"
            "custom/right-slant-end"
          ];

          modules-right = [
            "custom/left-slant-end"
            "pulseaudio"
            "custom/left-slant-divide"
            "memory"
            "custom/left-slant-divide"
            "cpu"
            "custom/left-slant-divide"
            "disk"
            "custom/left-slant-divide"
            "network"
            "custom/left-slant-divide"
            "tray"
          ];

          "custom/right-slant-end" = {
            format = "";
            tooltip = false;
          };

          "custom/right-slant-divide" = {
            format = "";
            tooltip = false;
          };

          "custom/left-slant-end" = {
            format = "";
            tooltip = false;
          };

          "custom/left-slant-divide" = {
            format = "";
            tooltip = false;
          };

          "sway/workspaces" = {
            disable-scroll = true;
            format = "{name}";
          };

          "clock#1" = {
            format = "{:%a}";
            tooltip = false;
          };

          "clock#2" = {
            format = "{:%H:%M}";
            tooltip = false;
          };

          "clock#3" = {
            format = "{:%m-%d}";
            tooltip = false;
          };

          "pulseaudio" = {
            format = "Vol: {volume}%";
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

          "memory" = {
            interval = 1;
            format = "Mem: {}%";
          };

          "cpu" = {
            interval = 1;
            format = "CPU: {}%";
          };

          "disk" = {
            interval = 1;
            format = "Disk: {percentage_used:2}%";
            path = "/";
          };

          "network" = {
            format = "{ifname}: {ipaddr}";
          };

          "tray" = {
            icon-size = 14;
            spacing = 4;
          };
        }
      ];

      style = ''
        * {
          min-height: 0;
          font-size: 12px;
          font-family: Terminus;
        }

        window {
          margin: 50px;
          padding: 50px;
        }

        window#waybar {
          background: rgba(0,0,0,0);
          color: ${colors.primary.foreground};
        }

        #custom-right-slant-end,
        #custom-left-slant-end {
          background: rgba(0,0,0,0);
          color: ${colors.normal.black};
        }

        #custom-right-slant-divide,
        #custom-left-slant-divide {
          background: ${colors.normal.black};
          color: ${colors.primary.foreground};
        }

        #workspaces,
        #clock.1,
        #clock.2,
        #clock.3,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk,
        #network,
        #tray {
          background: ${colors.normal.black};
          padding: 0 5px;
        }

        #workspaces button {
          padding: 0 2px;
          color: ${colors.primary.foreground};
        }
        #workspaces button.focused {
          color: ${colors.bright.red};
        }
        #workspaces button:hover {
          box-shadow: inherit;
          text-shadow: inherit;
        }
        #workspaces button:hover {
          background: #1a1a1a;
          border: #1a1a1a;
          padding: 0 3px;
        }

        #pulseaudio {
          color: ${colors.bright.blue};
        }
        #memory {
          color: ${colors.bright.green};
        }
        #cpu {
          color: ${colors.bright.magenta};
        }
        #battery {
          color: ${colors.bright.yellow};
        }
        #disk {
          color: ${colors.bright.red};
        }
        #network {
          color: ${colors.bright.cyan};
        }
      '';
    };

    programs.rofi = {
      enable = true;
      font = "Terminus 12";
      theme = "Arc-Dark";
    };

    services.kanshi = {
      enable = true;
      profiles = {
        default = {
          outputs = [
            {
              criteria = "DP-2";
              mode = "2560x1440";
              position = "0,0";
              transform = "90";
            }
            {
              criteria = "HDMI-A-2";
              mode = "3440x1440";
              position = "1440,900";
            }
          ];
        };
        default_vr = {
          outputs = [
            {
              criteria = "DP-2";
              mode = "2560x1440";
              position = "0,0";
              transform = "90";
            }
            {
              criteria = "HDMI-A-2";
              mode = "3440x1440";
              position = "1440,900";
            }
            {
              criteria = "DP-1";
              mode = "2880x1600";
              status = "disable";
            }
          ];
        };
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "monospace";
        font.size = 9;
        colors = colors;
        bell = {
          animation = "EaseOutCirc";
          duration = 100;
          color = "0x221414";
        };
      };
    };

    services.gammastep = {
      enable = true;
      tray = true;
      latitude = "42.375";
      longitude = "-71.234";
      temperature.day = 6500;
      temperature.night = 4500;
      settings = {
        general = {
          brightness-day = 1.00;
          brightness-night = 0.85;
          adjustment-method = "wayland";
        };
      };
    };

    gtk = {
      enable = true;
      font = {
        name = "Noto Sans 10";
      };
      iconTheme = {
        package = pkgs.arc-icon-theme;
        name = "Arc";
      };
      theme = {
        package = pkgs.arc-theme;
        name = "Arc-Dark";
      };
    };

    programs.mako = {
      enable = true;
      anchor = "top-right";
      font = "Terminus 12";
      backgroundColor = colors.primary.background;
      borderColor = colors.normal.blue;
      borderSize = 2;
      width = 500;
    };

    xresources.extraConfig = ''
      *saveLines: 8192
      *font: Terminus 8
      *letterSpace: 0
      *lineSpace: 0

      ! special
      *.foreground: ${colors.primary.foreground}
      *.background: ${colors.primary.background}

      *.color0: ${colors.normal.black}
      *.color1: ${colors.normal.red}
      *.color2: ${colors.normal.green}
      *.color3: ${colors.normal.yellow}
      *.color4: ${colors.normal.blue}
      *.color5: ${colors.normal.magenta}
      *.color6: ${colors.normal.cyan}
      *.color7: ${colors.normal.white}
      *.color8: ${colors.bright.black}
      *.color9: ${colors.bright.red}
      *.color10: ${colors.bright.green}
      *.color11: ${colors.bright.yellow}
      *.color12: ${colors.bright.blue}
      *.color13: ${colors.bright.magenta}
      *.color14: ${colors.bright.cyan}
      *.color15: ${colors.bright.white}

      ! rofi config
      rofi.color-enabled: true
      rofi.color-normal:  ${colors.primary.background},${colors.primary.foreground},${colors.normal.red},${colors.normal.yellow},${colors.primary.foreground}
      rofi.color-window:  ${colors.primary.background},${colors.bright.red}

      Xft.dpi: 96
    '';
  };
}
