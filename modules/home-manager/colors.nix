{ config, lib, pkgs, flake, ... }:
with lib;
{
  /*
  imports = [
    flake.catppuccin.homeManagerModules.catppuccin
  ];
  */

  options = {
    colors = mkOption {
      description = "Color scheme definition";
      default = {
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
    };
  };

  /*
  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "red";
    };
  };
  */
}
