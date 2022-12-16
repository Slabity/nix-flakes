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

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a535b9aa-97c2-4127-a1fe-0367fb375e87";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=system" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/a535b9aa-97c2-4127-a1fe-0367fb375e87";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=nix" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/a535b9aa-97c2-4127-a1fe-0367fb375e87";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=data" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AD68-C583";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/b46c39f6-8b40-4aae-bbea-0267f895a9ce"; } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.video.hidpi.enable = lib.mkDefault true;
}
