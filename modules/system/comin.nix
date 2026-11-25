{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.server = {
    hostname,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkIf;
    notify = pkgs.writeShellApplication {
      name = "comin-ntfy";
      runtimeInputs = [pkgs.curl];
      text = ''
        status="''${COMIN_STATUS:-}"
        sha="''${COMIN_GIT_SHA:-unknown}"
        phase="''${COMIN_PHASE:-}"
        case "$phase/$status" in
          deploy/done)
            title="${hostname} deployed"
            priority="low"
            tags="rocket"
            ;;
          deploy/failed | build/failed)
            title="${hostname} $phase failed"
            priority="high"
            tags="warning,x"
            ;;
          *) exit 0 ;;
        esac
        body="''${sha:0:8} ''${COMIN_GIT_MSG%%$'\n'*}"
        if [ -n "''${COMIN_ERROR_MSG:-}" ]; then
          body="$body"$'\n'"$COMIN_ERROR_MSG"
        fi
        curl -fsS --max-time 15 \
          -H "Title: $title" \
          -H "Priority: $priority" \
          -H "Tags: $tags" \
          -d "$body" \
          "https://${self.services.ntfy.fqdn}/deploy" >/dev/null || true
      '';
    };
  in {
    imports = [inputs.comin.nixosModules.comin];
    services.comin = mkIf self.hosts.${hostname}.autoDeploy {
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://${self.services.forgejo.fqdn}/sam-tee/dendrix.git";
          branches.main.name = "deploy";
        }
      ];
      buildAttemptsLimit = 3;
      postBuildCommand = getExe notify;
      postDeploymentCommand = getExe notify;
      exporter.listen_address = "127.0.0.1";
    };
  };
}
