{ config, lib, pkgs, flake, ... }:
{
  config = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      dotDir = ".config/zsh";

      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        path = "$ZDOTDIR/history";
        save = 100000;
        share = true;
        size = 100000;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "common-aliases"
          "compleat"
          "dirhistory"
          "encode64"
          "fasd"
          "git"
          "git-extras"
          "git-prompt"
          "per-directory-history"
          "sudo"
          "systemd"
          "vi-mode"
          "wd"
        ];
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = lib.concatStrings [
          "[](fg:white)"
          "[$time](inverted)"
          "[](fg:prev_bg bg:red)"
          "$directory"
          "[](fg:#3B76F0 bg:#FCF392)"
          "$git_branch"
          "$git_status"
          "$git_metric"
          "[](fg:#FCF392 bg:#030B16)"
          "$character"
        ];

        time = {
          disabled = false;
          time_format = "%R";
          format = "[$time]($style)";
        };

        directory = {
          format = "[ ﱮ $path ]($style)";
        };

        git_branch = {
          format = "[ $symbol$branch(:$remote_branch) ]($style)";
          symbol = "  ";
        };

        git_status = {
          format = "[$all_status]($style)";
        };

        git_metrics = {
          format = "([+$added]($added_style))[]($added_style)";
          added_style = "fg:#1C3A5E bg:#FCF392";
          deleted_style = "fg:bright-red bg:235";
          disabled = false;
        };

        cmd_duration = {
          format = "[  $duration ]($style)";
          style = "fg:bright-white bg:18";
        };

        character = {
          success_symbol = "[ \\$](bold green) ";
          error_symbol = "[ ✗](#E84D44) ";
        };

      };
    };

    home.packages = with pkgs; [
      zsh-completions
      nix-zsh-completions
    ];

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
