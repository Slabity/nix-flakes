{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./hardware
    ./workstation
  ];

  config = {
    environment.systemPackages = with pkgs; [
      nix-index
      nix-prefetch-git

      man-pages

      pciutils usbutils lsof
      pstree
      file bc psmisc

      unzip zip unrar

      efibootmgr
      smartmontools
      bind
    ];

    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    programs.git = {
      enable = true;
      config = {
        init = { defaultBranch = "main"; };
      };
      lfs.enable = true;
    };

    programs.atop.enable = true;

    programs.neovim = {
      enable = true;
    };

    services.fwupd.enable = true;

    nix = {
      package = pkgs.nixUnstable;
      gc.automatic = true;
      optimise.automatic = true;

      settings = {
        trusted-users = [ "root" "@wheel" ];

        substituters = [
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      # Make builds run with low priority so my system stays responsive
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";

      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      nixPath = [
        "nixos-config=/nix/var/nix/profiles/per-user/root/channels"
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "nixpkgs-overlays=/run/current-system/overlays"
      ];
    };

    nixpkgs = {
      overlays = [
        flake.overlays.personal
      ];
      config = {
        allowUnfree = true;
      };
    };

    system.extraSystemBuilderCmds = ''
      mkdir -pv $out/overlays
      ln -sv ${../../overlays/personal} $out/overlays/personal
    '';

    environment.sessionVariables = {
      XDG_CACHE_HOME  = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_BIN_HOME    = "\${HOME}/.local/bin";
      XDG_DATA_HOME   = "\${HOME}/.local/share";
      XDG_STATE_HOME  = "\${HOME}/.local/state";
      PATH = [ "\${XDG_BIN_HOME}" ];
    };
  };
}
