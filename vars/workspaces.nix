_: {
  flake.workspaceApps = {
    "1" = [{bundleId = "net.imput.helium";}];
    "2" = [{bundleId = "dev.zed.Zed";}];
    "3" = [{bundleId = "com.mitchellh.ghostty";}];
    "4" = [
      {
        bundleId = "com.github.Electron";
        titleRegex = "^T3 Code( \\(Beta\\))?$";
      }
    ];
    "5" = [{bundleId = "com.spotify.client";}];
  };
}
