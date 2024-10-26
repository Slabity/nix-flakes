{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./hardware.nix
    flake.nixosModules.default
    flake.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "mew";
  system.stateVersion = "23.11";

  time.timeZone = "America/New_York";

  workstation.enable = true;
  workstation.gaming.enable = true;

  users.users.slabity = {
    isNormalUser = true;
    extraGroups = [
      "wheel"  # Permissions for `sudo`
      "video"  # Permissions for GPU modesetting
      "render" # Permissions for GPU rendering
      "input"  # Permissions for input devices
      "dialout"
      "audio"
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit flake; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.slabity = {
      imports = [
        flake.homeManagerModules.default
        {
          workstation.enable = true;
        }
      ];
      home.stateVersion = "23.11";

      fullName = "${flake.secrets.personal.fullName}";
      email = "${flake.secrets.personal.email}";
    };
  };

  services.openssh.enable = true;

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;

  services.udev.packages = [ pkgs.picoprobe-udev-rules ];


}
