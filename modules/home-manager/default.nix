{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./colors.nix
    ./neovim.nix
    ./zsh.nix
    ./workstation
  ];

  options = {
    fullName = mkOption {
      description = "Full name of the user";
    };

    email = mkOption {
      description = "Email of the user";
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = config.fullName;
      userEmail = config.email;
    };

    programs.ssh = {
      enable = true;
      compression = true;
      controlMaster = "yes";
      forwardAgent = true;
    };

    nixpkgs.config = {
      overlays = [
        flake.overlays.personal
      ];
      config.allowUnfree = true;
    };
  };
}
