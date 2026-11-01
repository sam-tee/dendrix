{self, ...}: {
  # Single OAuth hub for Claude/Codex subscriptions; clients are wired up in
  # modules/ai/cliproxyapi.nix. Log in once per provider on the host:
  #   sudo -u cliproxyapi cliproxyapi -config /var/lib/cliproxyapi/config.yaml -no-browser --claude-login
  #   (likewise --codex-login), then paste the localhost redirect URL back in.
  flake.modules.nixos.cliproxyapi = {config, ...}: let
    inherit (self.services.cliproxyapi) port;
  in {
    services.cliproxyapi = {
      enable = true;
      settings = {
        server = {
          host = config.homelab.machineIP;
          inherit port;
        };
        access.api-keys = [{_secret = config.sops.secrets.cliproxyapi-key.path;}];
        # t3code's usage-limit widget reads quotas through the management API
        # (proxied from caddy, hence allow-remote); the client key doubles as
        # the management key. Uses the v8 `management` spelling (legacy
        # `remote-management` still works but prefer canonical).
        management = {
          allow-remote = true;
          secret-key._secret = config.sops.secrets.cliproxyapi-key.path;
        };
      };
    };
    systemd.services.cliproxyapi = {
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };
  };
}
