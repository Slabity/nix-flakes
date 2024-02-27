{
  description = "Personal flakes for my systems";

  inputs = {
    # Local flake that stores things I don't publish
    secrets.url = "flake:secrets";

    nixpkgs.url = "flake:nixpkgs";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-staging-next.url = "github:NixOS/nixpkgs/staging-next";
    nixos-hardware.url = "flake:nixos-hardware";
    home-manager = {
      url = "flake:home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
  let
    flake = self // inputs;
  in
  {
    nixosModules = { default = ./modules/nixos; };
    homeManagerModules = { default = ./modules/home-manager; };

    nixosConfigurations = with flake; {
      lapras = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit flake; };
        modules = [ ./systems/lapras ];
      };
      lucario = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit flake; };
        modules = [ ./systems/lucario ];
      };
      mew = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit flake; };
        modules = [ ./systems/mew ];
      };
      rotom = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit flake; };
        modules = [ ./systems/rotom ];
      };

      hyannis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit flake; };
        modules = [ ./systems/hyannis ];
      };
    };

    overlays = {
      personal = import ./overlays/personal;
    };
  };
}
