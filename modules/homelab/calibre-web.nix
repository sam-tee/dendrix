{self, ...}: {
  flake.modules.nixos.calibre-web = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.homelab) group machineIP user dataDir;
    # Server only needs ebook-convert, not TTS. speechSupport pulls
    # piper-tts (+ train closure: torch/librosa), broken on aarch64-linux.
    calibre-no-speech = pkgs.calibre.override {speechSupport = false;};
  in {
    services.calibre-web = {
      enable = true;
      inherit group user;
      calibrePackage = calibre-no-speech;
      dataDir = "${dataDir}/calibre-web";
      listen = {
        ip = machineIP;
        inherit (self.services.calibre-web) port;
      };
      options = {
        calibreLibrary = "${dataDir}/books";
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };
  };
}
