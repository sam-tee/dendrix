{
  flake.modules.nixos.nautilus = {pkgs, ...}: {
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };
    services.gnome.sushi.enable = true;
    environment.systemPackages = [pkgs.nautilus];
  };
}
