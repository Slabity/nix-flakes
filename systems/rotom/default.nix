{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    flake.nixosModules.default
    flake.home-manager.nixosModules.home-manager
  ];

  system.stateVersion = "23.11";
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  networking.hostName = "rotom";
  networking.useDHCP = true;

  time.timeZone = "America/New_York";

  users.users.slabity = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5235XOTxsFp/COvl8K67OO7adCk7vR/HZHRYFXZ8nnbZdQjRxWlnvHJXfHVeofFQ7iUeLCIX/4f/D5kAF+LKxBoDa5lkNMP4gDV5GX8XFCarnxnQbJCyXiRg0dIX/3POZLdeQNF82XaYjCN3oTjEzNrxZH7Mj7/6rj9J+9sCIxeDR7UATgRO55XfUwDKNYQYFRMiJVMwtn8K7IBZuM2GKO3FYtqrw3bOMFYApOtTmVwkRNyXJC3sisWQdDOzJ4I9wzyGFVLdTvEPoUygAKs0K/uit0WKxwxTD9XiPtBZww8sw0locdIaZDkSd12HUfEmp1j/PghiIWPZnfU0mHIc63uKJYg3DDBCU5SOYH3wCge3zkAhgWhpMXvyUiUe1Qd4SQepRVkL7YQZWkXdUNTKg1gIJ/yGYIYAdZoIu+nNJYE0JCObcN39HOt5XGYW5FbnMzv73OenrCM7y4Z8ac7K8GLiksWiN4MtkbKga9/uVH8E+j8goMjDBuokhZ5Kb6OuqRlYryRukiOiZ6Hf5g+VcUEojuAyWh3+Xodjlneqe/hbigYHe2v+AS/Thf8h/G84KSzDmoIsCFg7ISgBjYKRt7aAsIX92yNAs2+qjeoOip7l73WnvpzKGE5zK/pKU4j6+W253VjBXxw8rbq8mVEvha8CIooWP+fd3VtDG3k37/Q== slabity@nixos"
    ];
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

}
