final: prev:
{
  steam = (prev.steam.override {
    extraPkgs = pkgs: with pkgs; [
      gamemode.lib
      gamemode
    ];
  });

  bcachefs-tools = prev.bcachefs-tools.overrideAttrs(old: {
    buildInputs = old.buildInputs ++ [
      final.makeWrapper
    ];
    postFixup = old.postInstall or "" + ''
      wrapProgram $out/bin/mount.bcachefs.sh \
        --prefix PATH : "${final.lib.makeBinPath [ final.gawk final.util-linux final.coreutils ]}:$out/bin"
    '';
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
}
