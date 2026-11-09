{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.searchix = {
    config,
    lib,
    ...
  }: let
    inherit (self.services.searchix) fqdn port;
    # Track the same channel as this flake's nixpkgs input.
    nixpkgsUrl = (lib.importJSON (self + "/flake.lock")).nodes.nixpkgs.original.url;
    channelMatch = builtins.match "https://channels.nixos.org/([^/]+)/.*" nixpkgsUrl;
    channel =
      if channelMatch == null
      then throw "searchix: cannot derive channel from nixpkgs url ${nixpkgsUrl}"
      else builtins.head channelMatch;
  in {
    imports = [inputs.searchix.nixosModules.web];
    services.searchix = {
      enable = true;
      settings = {
        web = {
          inherit port;
          listenAddress = config.homelab.machineIP;
          baseURL = "https://${fqdn}";
        };
        importer.sources = {
          nixos = {
            enable = true;
            url = nixpkgsUrl;
          };
          nixpkgs = {
            enable = true;
            inherit channel;
            # programs.sqlite is only published on nixos-* channels
            programs.enable = lib.hasPrefix "nixos-" channel;
          };
          darwin.enable = true;
        };
      };
    };
    systemd.services.searchix = {
      after = ["tailscaled.service" "network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
