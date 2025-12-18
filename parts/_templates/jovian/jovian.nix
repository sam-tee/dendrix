{
  config,
  username,
  ...
}: {
  jovian = {
    decky-loader.enable = true;
    decky-loader.user = username;
    devices.steamdeck.enable = true;
    steam = {
      autoStart = true;
      user = "sam";
      desktopSession = config.nMods.de.environment;
      enable = true;
      updater.splash = "vendor";
    };
    hardware.has.amd.gpu = true;
    steamos = {
      useSteamOSConfig = true;
    };
  };
}
