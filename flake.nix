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
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla.url = "github:mozilla/nixpkgs-mozilla";
  };

  outputs = { self, ... }@inputs:
  {
    nixosModules = { default = ./modules/nixos; };
    homeManagerModules = { default = ./modules/home-manager; };

    nixosConfigurations = with self; with inputs; {
      lapras = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flake = self // inputs; };
        modules = [ ./systems/lapras ];
      };
      lucario = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flake = self // inputs; };
        modules = [ ./systems/lucario ];
      };
      mew = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flake = self // inputs; };
        modules = [ ./systems/mew ];
      };
    };

    overlays = {
      personal = import ./overlays/personal;
    };
  };
}
