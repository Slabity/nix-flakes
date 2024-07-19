{ config, lib, pkgs, flake, ... }:
{
  imports = [
    flake.nixos-hardware.nixosModules.framework-12th-gen-intel
  ];

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3160f4d1-4516-4743-a7e7-ee13684a0fca";
    fsType = "btrfs";
    options = [ "noatime,ssd,space_cache=v2,subvol=system" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/3160f4d1-4516-4743-a7e7-ee13684a0fca";
    fsType = "btrfs";
    options = [ "noatime,ssd,space_cache=v2,subvol=nix" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3160f4d1-4516-4743-a7e7-ee13684a0fca";
    fsType = "btrfs";
    options = [ "noatime,ssd,space_cache=v2,subvol=data" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6FCB-FA65";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/5f22cdd7-7172-4a65-9207-df4f71ce3081"; } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
