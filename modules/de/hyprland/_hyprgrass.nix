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
  version = "0.54.2";

  src = fetchFromGitHub {
    owner = "horriblename";
    repo = "hyprgrass";
    rev = "hl-0.54.2";
    hash = "sha256-XI9j4gXRMeMR+dycRMZ1QwbVK5xYoXDBbihFeGapv04=";
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
