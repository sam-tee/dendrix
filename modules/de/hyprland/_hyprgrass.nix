{
  lib,
  fetchFromGitHub,
  cmake,
  doctest,
  ninja,
  meson,
  wf-touch,
  nix-update-script,
  hyprlandPlugins,
}:
hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "hyprgrass";
  version = "0.56.2";

  src = fetchFromGitHub {
    owner = "horriblename";
    repo = "hyprgrass";
    rev = "8e605468cbf429791d61ddbfaeb14ff5e08fec3e";
    hash = "sha256-0nXTqzvZQSoTbpKcDmc4kciHmlIXfMZfLk5E1Ax9CP0=";
  };

  nativeBuildInputs = [cmake ninja meson doctest];

  buildInputs = [
    (wf-touch.overrideAttrs (oldAttrs: {
      src = fetchFromGitHub {
        owner = "WayfireWM";
        repo = "wf-touch";
        rev = "8974eb0f6a65464b63dd03b842795cb441fb6403";
        hash = "sha256-MjsYeKWL16vMKETtKM5xWXszlYUOEk3ghwYI85Lv4SE=";
      };
      mesonFlags = (oldAttrs.mesonFlags or []) ++ ["-Dtests=disabled"];
    }))
  ];

  dontUseCmakeConfigure = true;

  doCheck = true;

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    homepage = "https://github.com/horriblename/hyprgrass";
    description = "Hyprland plugin for touch gestures";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
