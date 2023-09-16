{ stdenv
, fetchFromGitLab
, cmake
, pkg-config
, extra-cmake-modules
, qt5
, libsForQt5
}: stdenv.mkDerivation rec {
  pname = "xwaylandvideobridge";
  version = "unstable-2023-03-28";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "b9e0c53570f55f4e8289f72ba78f3945e27e1a1a";
    hash = "sha256-tnWfpx/6aABe0VdIjOtx3oDL8C4uQo0yTd6VbAQT7/o=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtquickcontrols2
    qt5.qtx11extras
    libsForQt5.kdelibs4support
    (libsForQt5.kpipewire.overrideAttrs (oldAttrs: {
      version = "unstable-2023-03-28";

      src = fetchFromGitLab {
        domain = "invent.kde.org";
        owner = "plasma";
        repo = "kpipewire";
        rev = "ed99b94be40bd8c5b7b2a2f17d0622f11b2ab7fb";
        hash = "sha256-KhmhlH7gaFGrvPaB3voQ57CKutnw5DlLOz7gy/3Mzms=";
      };
    }))
  ];

  dontWrapQtApps = true;
}
