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

  users.users.tslabinski = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit flake; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.tslabinski = {
      imports = [
        flake.homeManagerModules.default
        {
          workstation.enable = true;
        }
      ];
      home.stateVersion = "22.11";

      fullName = "${flake.secrets.work.fullName}";
      email = "${flake.secrets.work.email}";
    };
  };

  services.openssh.enable = true;

  networking.hostName = "tslabinski-nixos";
  workstation.enable = true;

  services.globalprotect = {
    enable = true;
    csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
  };

  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
  ];
}
