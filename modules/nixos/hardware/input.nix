{ config, lib, pkgs, flake, ... }:
with lib;
let
  cfg = config.hardware.inputDevices;

  ps3Rules = ''
    # DualShock 3 controller, Bluetooth
    KERNEL=="hidraw*", KERNELS=="*054C:0268*", MODE="0660", TAG+="uaccess"
    # DualShock 3 controller, USB
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"
  '';

  wacomCintiq16ProRules = ''
    # Wacom Cintiq 16 Pro (DTH167)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="03b2", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="03b3", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="03b2", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="03b3", MODE="0666"
  '';
in
{
  options.hardware = {
    inputDevices = {
      ps3Controller = mkEnableOption "PS3 controller support";
      wacomCintiq16Pro = mkEnableOption "Wacom Cintiq 16 Pro support";
    };
  };

  config = {
    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      ${optionalString cfg.ps3Controller ps3Rules}
      ${optionalString cfg.wacomCintiq16Pro wacomCintiq16ProRules}
    '';
  };
}
