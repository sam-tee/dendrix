{
  flake.modules.nixos.sunshine = {
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) getExe singleton;
    mkExternalUp = scale:
      pkgs.writeShellApplication {
        name = "external-up";
        text = ''
          set -euo pipefail
          hyprctl output create headless EXTERNAL || true
          W="''${SUNSHINE_CLIENT_WIDTH:-1920}"
          H="''${SUNSHINE_CLIENT_HEIGHT:-1200}"
          FPS="''${SUNSHINE_CLIENT_FPS:-60}"
          hyprctl eval "$(printf 'hl.monitor({output="EXTERNAL", mode="%sx%s@%s", scale=${scale}})' "$W" "$H" "$FPS")"
        '';
      };
    externalDown = pkgs.writeShellApplication {
      name = "external-down";
      text = ''
        set -euo pipefail
        hyprctl output remove EXTERNAL || true
      '';
    };
    mkExternal = scale: {
      name = "External ${scale}";
      prep-cmd = singleton {
        do = "${getExe (mkExternalUp scale)}";
        undo = "${getExe externalDown}";
      };
    };
    mirrorPrep = pkgs.writeShellApplication {
      name = "mirror-prep";
      text = ''
        set -euo pipefail
        hyprctl output remove EXTERNAL || true
      '';
    };
  in {
    services.sunshine = {
      enable = true;
      openFirewall = true;
      settings = {
        capture = "wlr";
        output_name = "EXTERNAL";
        encoder = "quicksync";
        qsv_preset = "veryfast";
        qsv_coder = "cavlc";
        lan_encryption_mode = 0;
        packetsize = 0;
        fec_percentage = 5;
        hevc_mode = 1;
        av1_mode = 1;
        min_threads = 4;
        min_log_level = "info";
        origin_web_ui_allowed = "pc";
      };
      applications.apps = [
        {
          name = "Mirror Desktop";
          image-path = "desktop.png";
          prep-cmd = singleton {do = "${getExe mirrorPrep}";};
        }
        {
          name = "Steam Big Picture";
          image-path = "steam.png";
          detached = singleton "setsid steam steam://open/bigpicture";
          prep-cmd = singleton {
            do = "${getExe mirrorPrep}";
            undo = "setsid steam steam://close/bigpicture";
          };
        }
        (mkExternal "1.0")
        (mkExternal "1.25")
        (mkExternal "1.5")
        (mkExternal "2.0")
      ];
    };
  };
}
