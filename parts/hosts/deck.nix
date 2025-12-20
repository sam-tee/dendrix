{inputs, ...}: let
  inherit (import ./_helpers.nix inputs) mkHome;
  home = inputs.self.modules.homeManager;
in{
  homeConfigurations."deck" = mkHome {
    username = "deck";
    system = "x86_64-linux";
    homeModules = with home; [
      nixgl
      flatpak
      {
        services.flatpak.packages = [
          "com.bitwarden.desktop"
          "com.brave.Browser"
          "com.spotify.Client"
        ];
      }
    ];
  };
}
