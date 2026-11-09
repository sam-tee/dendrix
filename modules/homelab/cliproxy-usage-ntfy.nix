{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.cliproxy-usage-ntfy = {config, ...}: let
    inherit (self.services) cliproxyapi ntfy;
  in {
    imports = [inputs.cliproxy-usage-ntfy.nixosModules.default];
    services.cliproxy-usage-ntfy = {
      enable = true;
      managementKeyFile = config.sops.secrets.cliproxyapi-key.path;
      settings = {
        cliproxy.management_url = "http://${config.homelab.machineIP}:${toString cliproxyapi.port}/v0/management";
        ntfy = {
          server = "https://${ntfy.fqdn}";
          topic = "cliproxy";
          priority = "default";
        };
        poll = {
          interval_seconds = 60;
          arm_used_percent = 99.0;
          reset_used_percent = 90.0;
        };
        state.file = "${config.services.cliproxy-usage-ntfy.dataDir}/state.json";
      };
    };
  };
}
