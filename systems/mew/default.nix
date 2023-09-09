{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./hardware.nix
    flake.nixosModules.default
    flake.home-manager.nixosModules.home-manager
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "22.11";

  time.timeZone = "America/New_York";

  users.users.slabity = {
    isNormalUser = true;
    extraGroups = [
      "wheel"  # Permissions for `sudo`
      "video"  # Permissions for GPU modesetting
      "render" # Permissions for GPU rendering
      "input"  # Permissions for input devices
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
      home.stateVersion = "22.11";

      fullName = "${flake.secrets.personal.fullName}";
      email = "${flake.secrets.personal.email}";
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  networking.hostName = "mew";
  workstation.enable = true;
  workstation.gaming.enable = true;
}
