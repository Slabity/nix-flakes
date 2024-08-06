{ config, lib, pkgs, flake, ... }:
with lib;
{
  config = mkIf config.workstation.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        corefonts source-code-pro source-sans-pro source-serif-pro
        font-awesome terminus_font powerline-fonts google-fonts inconsolata noto-fonts
        noto-fonts-cjk unifont ubuntu_font_family nerdfonts
      ];
      fontconfig = {
        enable = true;
        defaultFonts.monospace = [
          #"Terminess Powerline"
          #"TerminessTTF Nerd Font Mono"
          "Terminess Nerd Font"
        ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        #hinting.enable = true;
        #antialias = true;
      };
    };
  };
}
