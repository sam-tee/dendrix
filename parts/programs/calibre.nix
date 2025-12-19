{
  flake.modules.nixos.calibre = {
    services = {
      calibre-server = {
      };
      calibre-web = {
        enable = true;
        group = "media";
      };
    };
  };
}
