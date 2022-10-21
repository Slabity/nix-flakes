{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    flake.nixos-hardware.nixosModules.common-pc
    flake.nixos-hardware.nixosModules.common-pc-ssd
    flake.nixos-hardware.nixosModules.common-cpu-intel
  ];

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/c1cfd094-9551-41cc-9587-18962f06c80d";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=system" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partuuid/c1cfd094-9551-41cc-9587-18962f06c80d";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=nix" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partuuid/c1cfd094-9551-41cc-9587-18962f06c80d";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=data" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7D47-9617";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/74793295-df8e-4373-906f-aeecf4bf35ff"; } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.video.hidpi.enable = lib.mkDefault true;
}
