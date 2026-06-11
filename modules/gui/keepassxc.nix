{
  flake.modules.homeManager.keepassxc = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) generators mkIf flip genAttrs const;
    isLinux = pkgs.stdenv.hostPlatform.isLinux;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    keepassConfig.generator = generators.toINI {};
    keepassConfig.value =
      {
        General.ConfigVersion = 2;

        General.BackupBeforeSave = true;

        General.UpdateCheckMessageShown = true;
        GUI.CheckForUpdates = false;
        GUI.CheckForUpdatesIncludeBetas = false;

        GUI.ToolButtonStyle = 4; # Follows platform style.
        Security.HideTotpPreviewPanel = true;

        Security.ClearSearch = true;
        Security.ClearSearchTimeout = 5; # 5 minutes.

        Security.LockDatabaseIdle = true;
        Security.LockDatabaseIdleSeconds = 3 * 60 * 60; # 3 hours.

        Browser.Enabled = true;
        SSHAgent.Enabled = true;
      }
      // lib.optionalAttrs isLinux {
        FdoSecrets.Enabled = true;
        FdoSecrets.ShowNotification = false;
        FdoSecrets.ConfirmDeleteItem = true;
        FdoSecrets.ConfirmAccessItem = true;
        FdoSecrets.UnlockBeforeSearch = true;
      };
  in {
    home.packages = mkIf [pkgs.keepassxc];
    home.file."Library/Application Support/KeePassXC/keepassxc.ini" = mkIf isDarwin keepassConfig;
    xdg.config.files."keepassxc/keepassxc.ini" = mkIf isLinux keepassConfig;
    xdg.mime-apps.default-applications =
      mkIf isLinux
      <| flip genAttrs
      (const "org.keepassxc.KeePassXC.desktop")
      ["application/x-keepass2"];
  };
}
