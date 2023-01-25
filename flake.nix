{
  description = "Personal flakes for my systems";

  inputs = {
    secrets.url = "flake:secrets";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
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
