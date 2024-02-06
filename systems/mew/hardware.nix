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

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "UUID=24cfa71c-57a3-4498-b2a2-2deb0a215345";
    fsType = "bcachefs";
    options = [ "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6D15-C36B";
    fsType = "vfat";
  };

  # Disable the odd Vulkan Loader stuff with this
  environment.variables = {
    DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  nixpkgs.config.rocmSupport = true;
}
