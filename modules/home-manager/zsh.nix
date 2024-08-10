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
          "$status"
          "$time"
          "$direnv"
          "$directory"
          "$git"
          "$character"
        ];

        status = {
          disabled = false;
          recognize_signal_code = true;
          format = "[Error code: $status]($style)\n";
          style = "fg:red bg:none";
        };

        time = {
          disabled = false;
          format = "[](fg:red)[󰥔 $time ]($style)";
          time_format = "%T";
          style = "fg:text bg:red";
        };

        directory = {
          format = "[](fg:prev_bg bg:surface0)[ $read_only$path ]($style)";
          read_only = " ";
          style = "fg:text bg:surface0";
        };

        character = {
          format = "[](fg:prev_bg bg:none) [\\$ ](fg:text)";
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
