{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./hardware.nix
    flake.nixosModules.default
    flake.home-manager.nixosModules.home-manager
  ];

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnsupportedSystem = true;

  networking.hostName = "rotom";
  networking.useDHCP = true;

  time.timeZone = "America/New_York";

  users.users.slabity = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit flake; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.slabity = {
      imports = [
        flake.homeManagerModules.default
      ];
      home.stateVersion = "23.11";

      fullName = "${flake.secrets.personal.fullName}";
      email = "${flake.secrets.personal.email}";
    };
  };

  services.openssh.enable = true;

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [ 
        "--network=host" 
        "--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];

      ports = [ "127.0.0.1:8123:8123" ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8123 ];
  };
}
