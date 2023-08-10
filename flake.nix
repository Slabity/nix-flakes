{
  description = "Personal flakes for my systems";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    nixos-hardware.url = "flake:nixos-hardware";
    home-manager = {
      url = "flake:home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Local flake that stores things I don't publish
    secrets.url = "flake:secrets";
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
