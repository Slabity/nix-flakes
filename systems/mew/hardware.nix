{ config, lib, pkgs, flake, ... }:
{
  imports = [
    flake.nixos-hardware.nixosModules.common-pc
    flake.nixos-hardware.nixosModules.common-cpu-amd
    flake.nixos-hardware.nixosModules.common-gpu-amd
  ];

  hardware.enableRedistributableFirmware = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "kmemleak=on" ];

  boot.kernelPatches = [ {
    name = "enable-kmemleak";
    patch = null;
    extraConfig = ''
      DEBUG_KMEMLEAK y
    '';
  } ];

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

  fileSystems."/home/steam" = {
    device = "/dev/disk/by-uuid/6d9f38d0-68a9-41b6-a66b-2859156ef46b";
    fsType = "btrfs";
    options = [ "noatime,ssd,space_cache=v2,subvol=steam" ];
  };

  # Disable the odd Vulkan Loader stuff with this
  environment.variables = {
    DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  nixpkgs.config.rocmSupport = true;
}
