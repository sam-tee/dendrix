{self, ...}: {
  flake.modules.nixos = {
    wm = self.modules.nixos.imv;
    imv = {pkgs, ...}: {
      environment.systemPackages = [pkgs.imv];
      xdg.mime.defaultApplications = {
        "image/avif" = "imv-dir.desktop";
        "image/bmp" = "imv-dir.desktop";
        "image/gif" = "imv-dir.desktop";
        "image/heif" = "imv-dir.desktop";
        "image/jpeg" = "imv-dir.desktop";
        "image/jxl" = "imv-dir.desktop";
        "image/png" = "imv-dir.desktop";
        "image/svg+xml" = "imv-dir.desktop";
        "image/tiff" = "imv-dir.desktop";
        "image/webp" = "imv-dir.desktop";
      };
    };
  };
}
