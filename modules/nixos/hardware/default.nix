{ config, lib, pkgs, flake, ... }:
with lib;
{
  imports = [
    ./iosched.nix
    ./input.nix
  ];
}
