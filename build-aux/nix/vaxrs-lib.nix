{
  lib,
  self,
  rustPlatform,
  pkg-config,
  freetype,
  libGL,
  libxkbcommon,
  pipewire,
  wayland,
  xorg,
}:
rustPlatform.buildRustPackage rec {
  pname = "vaxrs-lib";
  version = "unstable";
  src = lib.cleanSource "${self}";

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    freetype
    libGL
    libxkbcommon
    pipewire
    rustPlatform.bindgenHook
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  LIBRARY_PATH = lib.makeLibraryPath buildInputs;

  meta = with lib; {
    description = "";
    license = licenses.gpl3;
    maintainers = with maintainers; [shymega];
  };
}
