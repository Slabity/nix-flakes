{ config, lib, pkgs, flake, ... }:
{
  imports = [
    flake.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  system.stateVersion = "23.11";

  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  /*fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };*/

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
