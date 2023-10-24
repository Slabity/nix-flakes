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

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      settings = {
        "$mod" = "SUPER";

        general = {
          gaps_in = "2";
          gaps_out = "5";
          border_size = "2";
        };

        decoration = {
          rounding = "5";
          blur = {
            enabled = "true";
            size = "3";
            passes = "1";
          };
        };

        animations = {
          enabled = "true";
        };

        misc = {
          "disable_hyprland_logo" = "true";
          "disable_splash_rendering" = "true";
        };

        bind = [
          "$mod, Return, exec, ${pkgs.alacritty}/bin/alacritty"
          "$mod, d,      exec, ${pkgs.wofi}/bin/wofi --show run"

          "$mod SHIFT, q,      killactive"
          "$mod SHIFT, space,  togglefloating"

          "$mod, f, fullscreen"

          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"

          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, j, movewindow, d"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Scratchpad, uses keycode 21 (`=` key)
          "$mod,       code:21, togglespecialworkspace"
          "$mod SHIFT, code:21, movetoworkspace, special"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        monitor = [
          "DP-3,2560x1440@59.951,0x0,1.0"
          "DP-3,transform,1"
          "DP-1,3440x1440@164.899994,1440x1120,1.0"
        ];
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
      package = null;

      config = {
        modifier = "Mod4";
        bars = [];
        window = {
          titlebar = false;
        };
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
        focus.newWindow = "urgent";
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
          { command = "dbus-update-activation-environment --systemd --all"; }
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
          all: inherit;
          min-height: 0;
          min-width: 0;
          margin: 0;
          padding: 0;
          border: 0;
          border-radius: 0;
          font-weight: normal;
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

    programs.wofi = {
      enable = true;
      settings = {
        width = 400;
      };
      style = ''
        * {
          font-family: monospace;
        }

        window {
          margin: 0px;
          border: 1px solid ${colors.normal.magenta};
          background-color: ${colors.primary.background};
        }

        #input {
          margin: 5px;
          border: none;
          color: ${colors.primary.foreground};
          background-color: ${colors.primary.background};
        }

        #inner-box {
          margin: 5px;
          border: none;
          background-color: ${colors.primary.background};
        }

        #outer-box {
          margin: 5px;
          border: none;
          background-color: ${colors.primary.background};
        }

        #scroll {
          margin: 0px;
          border: none;
        }

        #text {
          margin: 5px;
          border: none;
          color: ${colors.primary.foreground};
        }

        #entry:selected {
          background-color: ${colors.primary.background};
        }
      '';
    };

    services.kanshi = let
      primary = {
        criteria = "Dell Inc. AW3423DWF H5K52S3";
        mode = "3440x1440@164.9Hz";
        position = "1440,1120";
      };
      secondary = {
        criteria = "HYC CO., LTD.  Unknown";
        mode = "2560x1440@59.95Hz";
        position = "0,0";
        transform = "90";
      };
      tablet = {
        criteria = "Wacom Tech Cintiq Pro_16 2CQ0191001523";
        mode = "3840x2160";
        position = "4880,2460";
      };
    in {
      enable = true;
      systemdTarget = "sway-session.target";
      profiles = {
        default = {
          outputs = [
            primary
            secondary
          ];
        };
        default_tablet = {
          outputs = [
            primary
            secondary
            tablet
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

    services.mako = {
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

    services.easyeffects = {
      enable = true;
      preset = "Default";
    };
  };
}
