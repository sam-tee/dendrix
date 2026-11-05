{self, ...}: {
  flake.modules.darwin = {
    default = self.modules.darwin.spotlight;
    spotlight = {
      config,
      lib,
      ...
    }: let
      inherit (lib) boolToString concatMapStrings escapeShellArg;
      user = escapeShellArg config.system.primaryUser;
      # Symbolic hotkey entry: parameters are (ascii char, virtual keycode, modifier mask).
      hotkey = enabled: parameters:
        escapeShellArg (
          "<dict><key>enabled</key><${boolToString enabled}/>"
          + "<key>value</key><dict><key>parameters</key><array>"
          + concatMapStrings (p: "<integer>${toString p}</integer>") parameters
          + "</array><key>type</key><string>standard</string></dict></dict>"
        );
      ctrlSpace = [32 49 262144];
    in {
      # Merge individual entries with -dict-add: CustomUserPreferences would
      # replace the whole AppleSymbolicHotKeys dict and reset other shortcuts.
      system.activationScripts.postActivation.text = ''
        echo >&2 "spotlight hotkey..."
        launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- \
          defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add \
            60 ${hotkey false ctrlSpace} \
            64 ${hotkey true ctrlSpace}
        launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- \
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };
  };
}
