_: {
  flake.modules.darwin.xcode = _: {
    homebrew.masApps."Xcode" = 497799835;
    system.activationScripts.postActivation.text = ''
      xcode=/Applications/Xcode.app
      if [ -d "$xcode" ]; then
        if [ "$(/usr/bin/xcode-select -p 2>/dev/null)" != "$xcode/Contents/Developer" ]; then
          echo "selecting $xcode as active developer directory..." >&2
          /usr/bin/xcode-select --switch "$xcode/Contents/Developer"
        fi
        if ! /usr/bin/xcodebuild -license check >/dev/null 2>&1; then
          echo "accepting Xcode license..." >&2
          /usr/bin/xcodebuild -license accept
        fi
        if ! /usr/bin/xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
          echo "running Xcode first-launch setup..." >&2
          /usr/bin/xcodebuild -runFirstLaunch
        fi
      fi
    '';
  };
}
