{ config, lib, pkgs, flake, ... }:
{
  imports = [
    flake.nixos-hardware.nixosModules.common-pc
    flake.nixos-hardware.nixosModules.common-cpu-amd
    flake.nixos-hardware.nixosModules.common-gpu-amd
  ];

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8e220c5a-93f7-415b-a3fa-ce1f823dd145";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=system" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8e220c5a-93f7-415b-a3fa-ce1f823dd145";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=data" ];
  };

  hardware.opengl.package = let
    staging = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/tarball/staging-next") { config = config.nixpkgs.config; };
    llvm15 = import (builtins.fetchTarball "https://github.com/rrbutani/nixpkgs/tarball/feature/llvm-15") { config = config.nixpkgs.config; };
  in (staging.mesa.override { llvmPackages = llvm15.llvmPackages_15; enableOpenCL = false; }).drivers;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.video.hidpi.enable = lib.mkDefault true;
}
