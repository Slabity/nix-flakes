{ config, lib, pkgs, flake, ... }:
{
  imports = [
    flake.nixos-hardware.nixosModules.common-pc
    flake.nixos-hardware.nixosModules.common-gpu-nvidia
    flake.nixos-hardware.nixosModules.common-cpu-intel
    flake.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme
  ];

  hardware.enableRedistributableFirmware = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload.enable = false;
    };
  };

  /*
  environment.etc."gbm/nvidia-drm_gbm.so".source = "${config.boot.kernelPackages.nvidiaPackages.stable}/lib/libnvidia-allocator.so";
  environment.etc."egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
  */

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dec6e4b4-62d9-454e-8341-c52459d03e27";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=sysroot" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/dec6e4b4-62d9-454e-8341-c52459d03e27";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=nix" ];
  };

  fileSystems."/nix/store" = {
    device = "/dev/disk/by-uuid/dec6e4b4-62d9-454e-8341-c52459d03e27";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=nix/store" ];
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/dec6e4b4-62d9-454e-8341-c52459d03e27";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=var" ];
  };

  fileSystems."/subvols" = {
    device = "/dev/disk/by-uuid/dec6e4b4-62d9-454e-8341-c52459d03e27";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/dec6e4b4-62d9-454e-8341-c52459d03e27";
    fsType = "btrfs";
    options = [ "noatime,compress=zstd:1,ssd,space_cache=v2,subvol=home" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B83D-2223";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/215e28ca-155d-4b20-8615-fe2f28a37a29"; } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.video.hidpi.enable = lib.mkDefault true;

  services.tlp = {
    enable = true;
    settings = {
      USB_DENYLIST="0bda:8156";
    };
  };
}
