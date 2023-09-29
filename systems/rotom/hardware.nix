{ config, lib, pkgs, flake, ... }:
{
  imports = [
    "${flake.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  system.stateVersion = "23.11";
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnsupportedSystem = true;
}
