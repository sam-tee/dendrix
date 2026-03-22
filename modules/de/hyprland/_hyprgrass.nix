{
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  meson,
  wf-touch,
  hyprland,
  hyprlandPlugins,
}:
hyprlandPlugins.mkHyprlandPlugin (finalAttrs: {
  pluginName = "hyprgrass";
  version = "0.54.2";

  src = fetchFromGitHub {
    owner = "horriblename";
    repo = "hyprgrass";
    rev = "hl-${finalAttrs.version}";
    hash = "sha256-XI9j4gXRMeMR+dycRMZ1QwbVK5xYoXDBbihFeGapv04=";
  };

  nativeBuildInputs = [cmake ninja meson];

  buildInputs = [wf-touch];

  meta = with lib; {
    homepage = "https://github.com/horriblename/hyprgrass";
    description = "Hyprland plugin for touch gestures";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
})
