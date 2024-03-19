{ config, lib, pkgs, flake, ... }:
{
  config = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      dotDir = ".config/zsh";
      initExtraBeforeCompInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

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

      initExtra = "source ${./powerlevel10k.zsh}";
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
