{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.nix-pr = {config, ...}: {
    imports = [inputs.nixpkgs-pr-tracker.nixosModules.default];
    services.nixpkgs-pr-tracker = {
      enable = true;
      host = config.homelab.machineIP;
      inherit (self.services.nix-pr) port;
      ntfy = {
        server = "https://${self.services.ntfy.fqdn}";
        topic = "nixpkgs";
      };
    };
  };
}
