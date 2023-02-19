final: prev:
{
  wine = prev.wine.override ({
    wineRelease = "staging";
    wineBuild = "wineWow";

    pngSupport = true;
    jpegSupport = true;
    tiffSupport = true;
    fontconfigSupport = true;
    tlsSupport = true;
    mpg123Support = true;
    pulseaudioSupport = true;

    openglSupport = true;
    openalSupport = true;
    openclSupport = true;
    vulkanSupport = true;
    sdlSupport = true;
  });

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

  discordcanary = prev.discordcanary.override { nss = final.nss_latest; };
}
