{self, ...}: {
  flake.modules.nixos.site = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (config.homelab) dataDir group user;
    inherit (self.services.site) port;
    wwwRoot = "${dataDir}/www";
    generateIndex = pkgs.writeShellApplication {
      name = "generate-site-index";
      runtimeInputs = with pkgs; [
        coreutils
        findutils
        gnused
      ];
      text = ''
        set -euo pipefail

        root="$1"
        tmp="$(mktemp "$root/.index.html.XXXXXX")"

        escape_html() {
          sed \
            -e 's/&/\&amp;/g' \
            -e 's/</\&lt;/g' \
            -e 's/>/\&gt;/g' \
            -e 's/"/\&quot;/g' \
            -e "s/'/\&#39;/g"
        }

        {
          cat <<'EOF'
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Sites</title>
          <style>
            :root {
              color-scheme: light dark;
              font-family: system-ui, sans-serif;
            }
            body {
              margin: 0;
              min-height: 100vh;
              display: grid;
              place-items: start center;
              background: Canvas;
              color: CanvasText;
            }
            main {
              width: min(56rem, calc(100% - 2rem));
              padding: 4rem 0;
            }
            h1 {
              margin: 0 0 1.5rem;
              font-size: 2rem;
              font-weight: 650;
            }
            ul {
              display: grid;
              gap: 0.75rem;
              margin: 0;
              padding: 0;
              list-style: none;
            }
            a {
              display: block;
              padding: 0.9rem 1rem;
              border: 1px solid color-mix(in srgb, CanvasText 18%, transparent);
              border-radius: 0.5rem;
              color: inherit;
              text-decoration: none;
            }
            a:hover,
            a:focus-visible {
              border-color: LinkText;
              color: LinkText;
            }
          </style>
        </head>
        <body>
          <main>
            <h1>Sites</h1>
            <ul>
        EOF

          find "$root" -mindepth 2 -maxdepth 2 -name index.html -type f -print \
            | while IFS= read -r index; do
              page="$(basename "$(dirname "$index")")"
              escaped_page="$(printf '%s' "$page" | escape_html)"
              printf '      <li><a href="/%s/">%s</a></li>\n' "$page" "$escaped_page"
            done \
            | sort

          cat <<'EOF'
            </ul>
          </main>
        </body>
        </html>
        EOF
        } > "$tmp"

        mv "$tmp" "$root/index.html"
      '';
    };
  in {
    systemd.tmpfiles.rules = [
      "d ${wwwRoot} 0755 ${user} ${group} - -"
    ];

    systemd.services.generate-site-index = {
      description = "Generate static site index";
      wantedBy = ["multi-user.target"];
      before = ["caddy.service"];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        Group = group;
        ExecStart = "${lib.getExe generateIndex} ${wwwRoot}";
      };
    };

    services.caddy = {
      enable = true;
      inherit group user;
      virtualHosts.":${toString port}" = {
        extraConfig = ''
          root * ${wwwRoot}
          file_server
        '';
      };
    };
  };
}
