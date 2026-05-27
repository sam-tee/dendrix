{
  lib,
  fetchFromGitHub,
  cmake,
  doctest,
  ninja,
  meson,
  wf-touch,
  nix-update-script,
  hyprland,
  hyprlandPlugins,
}:
hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "hyprgrass";
  version = "0.55.2";

  src = fetchFromGitHub {
    owner = "horriblename";
    repo = "hyprgrass";
    tag = "hl-0.55.2";
    hash = "sha256-5YU8CV5/tjgyO9V8MJQ0h5OlshpM+e39QZj8lBfTJRU=";
  };

  nativeBuildInputs = [cmake ninja meson doctest];

  buildInputs = [wf-touch];

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
