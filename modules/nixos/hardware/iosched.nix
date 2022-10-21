{ config, lib, pkgs, flake, ... }:
with lib;
let
  cfg = config.hardware.ioSchedulers;

  ioScheduler = types.enum [
    "none"
    "mq-deadline"
    "bfq"
    "kyber"
  ];
in
{
  options.hardware = {
    ioSchedulers = {
      nvme = mkOption {
        type = ioScheduler;
        default = "none";
        description = "IO scheduler for NVMe SSDs";
      };

      sataSSD = mkOption {
        type = ioScheduler;
        default = "mq-deadline";
        description = "IO scheduler for SATA SSDs";
      };

      sataHDD = mkOption {
        type = ioScheduler;
        default = "bfq";
        description = "IO scheduler for SATA HDDs";
      };

      emmc = mkOption {
        type = ioScheduler;
        default = "mq-deadline";
        description = "IO scheduler for eMMC SSDs";
      };
    };
  };

  config = {
    services.udev.extraRules = ''
      # Set scheduler for NVMe
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="${cfg.nvme}"

      # Set scheduler for SSD
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.sataSSD}"

      # set scheduler for rotating disks
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="${cfg.sataHDD}"

      # set scheduler for eMMC
      ACTION=="add|change", KERNEL=="mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.emmc}"
    '';
  };
}
