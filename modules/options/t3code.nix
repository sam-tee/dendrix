# T3 Code: package (with optional extras), declarative settings and a server service
{lib, ...}: let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;

  # Extras are the package's `enable*` override flags, e.g. extras.enableGitHub
  extraFlags = pkgs:
    lib.functionArgs pkgs.t3code.override
    |> builtins.attrNames
    |> builtins.filter (lib.hasPrefix "enable");
in {
  flake.modules.generic.default = {
    config,
    options,
    pkgs,
    username,
    ...
  }: let
    cfg = config.programs.t3code;
    svc = cfg.service;
    jsonFormat = pkgs.formats.json {};
    applySettings = file: value:
      lib.optionalString (value != {})
      "apply ${cfg.home}/userdata/${file} ${jsonFormat.generate "t3code-${file}" value}";
    # The app saves settings by replacing the file, so a read-only hjem
    # symlink breaks; seed/merge into its own writable files on activation
    settingsScript = pkgs.writeShellScript "t3code-settings" ''
      set -eu
      PATH=${lib.makeBinPath [pkgs.coreutils pkgs.jq]}
      mkdir -p ${cfg.home}/userdata
      apply() {
        # Materialise files left as store symlinks by the old hjem setup
        if [ -L "$1" ]; then
          src=$(readlink -f "$1")
          rm "$1"
          [ ! -e "$src" ] || install -m 644 "$src" "$1"
        fi
        if [ ! -s "$1" ]; then
          install -m 644 "$2" "$1"
        ${lib.optionalString (cfg.settingsMode == "merge") ''
        else
          tmp=$(mktemp "$1.XXXXXX")
          if jq --slurpfile nix "$2" '. * $nix[0]' "$1" > "$tmp"; then
            chmod 644 "$tmp"
            mv "$tmp" "$1"
          else
            rm -f "$tmp"
            echo "t3code: failed to merge settings into $1" >&2
          fi
      ''}
        fi
      }
      ${applySettings "settings.json" cfg.settings}
      ${applySettings "client-settings.json" cfg.uiSettings}

      # T3's secret store names files after the base64url source id
      ${lib.concatMapAttrsStringSep "\n" (id: file: ''
          if [ -r ${file} ]; then
            (umask 077 && mkdir -p ${cfg.home}/userdata/secrets \
              && tr -d '\n' < ${file} > ${cfg.home}/userdata/secrets/usage-limit-source-$(printf %s ${lib.escapeShellArg id} | basenc --base64url | tr -d =).bin)
          else
            echo "t3code: can't read usage limit secret ${file}" >&2
          fi
        '')
        cfg.usageLimitSecrets}
    '';
    # pkgs.stdenv.hostPlatform.is<Platform> causes infinite recursion so bodge
    isLinux = options ? systemd;
    isDarwin = options ? launchd;
  in {
    options.programs.t3code = {
      enable = mkEnableOption "T3 Code, a GUI and server for coding agents";

      package = mkOption {
        type = types.nullOr types.package;
        default = pkgs.t3code.override (
          lib.filterAttrs (_: enable: enable != null) cfg.extras
        );
        defaultText = lib.literalExpression "pkgs.t3code.override programs.t3code.extras";
        description = ''
          T3 Code package to install. Defaults to `pkgs.t3code` overridden with
          {option}`programs.t3code.extras`. Null installs nothing (e.g. when the
          app comes from a Homebrew cask) while still managing settings.
        '';
      };

      extras = lib.genAttrs (extraFlags pkgs) (flag:
        mkOption {
          type = types.nullOr types.bool;
          default = null;
          example = true;
          description = "Package override `${flag}`. Null keeps the package default.";
        });

      user = mkOption {
        type = types.str;
        default = username;
        defaultText = lib.literalExpression "username";
        description = "User whose T3 Code settings are managed and who runs the server.";
      };

      home = mkOption {
        type = types.str;
        default = "${config.xdg.dirs.configDir}/t3";
        defaultText = lib.literalExpression ''"''${config.xdg.dirs.configDir}/t3"'';
        description = "T3 Code state directory, exported as `T3CODE_HOME`.";
      };

      settings = mkOption {
        inherit (jsonFormat) type;
        default = {};
        example = {
          defaultAutoPull = true;
          enableProviderUpdateChecks = false;
        };
        description = ''
          Server settings applied to {file}`''${home}/userdata/settings.json`
          on activation according to {option}`programs.t3code.settingsMode`.
          The file stays writable by the app.
        '';
      };

      uiSettings = mkOption {
        inherit (jsonFormat) type;
        default = {};
        example = {
          fontSizeCode = 14;
          notificationMode = "notifications";
        };
        description = ''
          Desktop/client settings applied to
          {file}`''${home}/userdata/client-settings.json`, like
          {option}`programs.t3code.settings`.
        '';
      };

      usageLimitSecrets = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {"cliproxy-myhost" = "/run/secrets/cliproxyapi-key";};
        description = ''
          Runtime secret files (e.g. sops-nix paths) installed on activation
          into T3's secret store as the management key of the matching
          `usageLimitSources` entry, keeping it out of the Nix store and
          {file}`settings.json`.
        '';
      };

      settingsMode = mkOption {
        type = types.enum ["merge" "seed"];
        default = "merge";
        description = ''
          How {option}`programs.t3code.settings` and
          {option}`programs.t3code.uiSettings` reach the app's files on
          activation. `merge` deep-merges them into the existing JSON, so
          declared keys win and app-written keys are kept (keys later removed
          from Nix stay in the file). `seed` only writes files that don't
          exist yet, so later Nix changes don't reach existing installs.
        '';
      };

      service = {
        enable = mkEnableOption "the T3 Code server (`t3 serve`) as a systemd service (NixOS only)";

        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          example = "0.0.0.0";
          description = "Address the server binds to.";
        };

        port = mkOption {
          type = types.port;
          default = 3773;
          description = "Port the server listens on.";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to open {option}`programs.t3code.service.port` in the firewall.";
        };

        workingDirectory = mkOption {
          type = types.str;
          default = config.users.users.${cfg.user}.home;
          defaultText = lib.literalExpression "config.users.users.\${programs.t3code.user}.home";
          description = "Working directory of the server.";
        };

        environment = mkOption {
          type = types.attrsOf types.str;
          default = {};
          example = {FJ_FALLBACK_HOST = "https://git.example.com";};
          description = "Extra environment variables for the server.";
        };

        environmentFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          example = "/run/secrets/t3code.env";
          description = "EnvironmentFile for the server, e.g. a sops-nix secret with API keys.";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Extra arguments passed to `t3 serve`.";
        };
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        assertions = [
          {
            assertion = svc.enable -> isLinux && cfg.package != null;
            message = "programs.t3code.service.enable is NixOS-only and requires programs.t3code.package to be set.";
          }
        ];
        environment.systemPackages = lib.optional (cfg.package != null) cfg.package;
      }

      (lib.optionalAttrs isLinux {
        environment.sessionVariables.T3CODE_HOME = cfg.home;
        system.activationScripts.t3code-settings = {
          # setupSecrets: sops-nix secrets referenced by usageLimitSecrets
          deps = ["users"] ++ lib.optional (config.system.activationScripts ? setupSecrets) "setupSecrets";
          text = ''
            ${pkgs.util-linux}/bin/runuser -u ${cfg.user} -- ${settingsScript} \
              || echo "warning: failed to apply t3code settings" >&2
          '';
        };
        networking.firewall.allowedTCPPorts = mkIf (svc.enable && svc.openFirewall) [svc.port];
        systemd.services.t3code = mkIf svc.enable {
          description = "T3 Code server";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          # Activation runs before units restart, so this picks up merged settings
          restartTriggers = [settingsScript];
          environment = {T3CODE_HOME = cfg.home;} // svc.environment;
          serviceConfig = {
            User = cfg.user;
            WorkingDirectory = svc.workingDirectory;
            ExecStart = lib.escapeShellArgs ([
                (lib.getExe' cfg.package "t3")
                "serve"
                "--host"
                svc.host
                "--port"
                (toString svc.port)
              ]
              ++ svc.extraArgs);
            EnvironmentFile = mkIf (svc.environmentFile != null) [svc.environmentFile];
            Restart = "always";
            RestartSec = 10;
          };
        };
      })

      (lib.optionalAttrs isDarwin {
        environment.variables.T3CODE_HOME = cfg.home;
        # After sops-nix's mkAfter secret install
        system.activationScripts.postActivation.text = lib.mkOrder 2000 ''
          /usr/bin/sudo -u ${cfg.user} ${settingsScript} \
            || echo "warning: failed to apply t3code settings" >&2
        '';
        launchd.user.agents.t3code-env = {
          command = "/bin/launchctl setenv T3CODE_HOME ${cfg.home}";
          serviceConfig.RunAtLoad = true;
        };
      })
    ]);
  };
}
