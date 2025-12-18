{
  config,
  inputs,
  pkgs,
  ...
}: {
  services.flatpak = {
    enable = true;
    update.auto.enable = true;
    uninstallUnmanaged = true;
    packages = [
      "com.bitwarden.desktop"
      "com.brave.Browser"
      "com.discordapp.Discord"
      "com.spotify.Client"
    ];
  };
  nixGL = {
    packages = inputs.nixgl.packages;
    installScripts = ["mesa"];
  };
  hMods = {
    de.enablePM = true;
    packages = {
      ghostty = {
        enable = true;
        package = config.lib.nixGL.wrap pkgs.ghostty;
      };
    };
  };
}
