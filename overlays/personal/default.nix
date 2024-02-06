final: prev:
{
  steam = (prev.steam.override {
    extraPkgs = pkgs: with pkgs; [
      gamemode.lib
      gamemode
    ];
  });

  opentabletdriver = prev.opentabletdriver.overrideAttrs(old: {
    version = "0.6.0.6";

    src = prev.fetchFromGitHub {
      owner = "Slabity";
      repo = "OpenTabletDriver";
      rev = "master";
      sha256 = "sha256-YYxs9pHJvpMVasUeU06rpNn54esmgP3Wbi/LmPGqhGk=";
    };
  });

  xwaylandvideobridge = final.libsForQt5.callPackage ./xwaylandvideobridge.nix { };
}
