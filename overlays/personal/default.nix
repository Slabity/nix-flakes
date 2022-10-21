final: prev:
{
  remarkable-mouse = prev.remarkable-mouse.overrideAttrs (old: {
    src = fetchGit {
      url = "https://github.com/davidsharp/remarkable_mouse";
    };

    propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.libdrm ];
  });

  preferredRustChannel = final.rustChannelOf {
    sha256 = "sha256-eOelUXavAqK4nMCGz5RrQNz5SGAtB+o6X/V3IkRmEao=";
    date = "2022-07-22";
    channel = "nightly";
  };

  vulkan-loader = prev.vulkan-loader.overrideAttrs (old: {
    cmakeFlags = [
      "-DSYSCONFDIR=${final.addOpenGLRunpath.driverLink}/share"
      "-DVULKAN_HEADERS_INSTALL_DIR=${final.vulkan-headers}"
      "-DBUILD_WSI_WAYLAND_SUPPORT=ON"
      "-DCMAKE_INSTALL_INCLUDEDIR=${final.vulkan-headers}/include"
    ];
  });

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

  freecad = prev.freecad.overrideAttrs(old: {
    version = "0.20";

    src = prev.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = "master";
      hash = "sha256-MjQLDn5174igveyzpLmGV7jg/3xpLBGVoeRB0ZU74XI=";
    };
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

  discord = prev.discord.override { nss = final.nss_latest; };
}
