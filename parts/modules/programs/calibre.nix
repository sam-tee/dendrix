{
  flake.modules.nixos.homelab = {
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
