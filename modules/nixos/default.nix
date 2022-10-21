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

      git
      man-pages

      pciutils usbutils atop
      pstree
      file bc psmisc

      unzip zip unrar
    ];

    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
    };

    nix = {
      package = pkgs.nixUnstable;
      gc.automatic = true;
      optimise.automatic = true;

      settings.trusted-users = [ "root" "@wheel" ];

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
        flake.mozilla.overlay
        flake.neovim-nightly-overlay.overlay
        flake.overlays.personal
      ];
      config.allowUnfree = true;
    };

    system.extraSystemBuilderCmds = ''
      mkdir -pv $out/overlays
      ln -sv ${flake.mozilla} $out/overlays/mozilla
      ln -sv ${flake.neovim-nightly-overlay} $out/overlays/neovim
      ln -sv ${../../overlays/personal} $out/overlays/personal
    '';
  };
}
