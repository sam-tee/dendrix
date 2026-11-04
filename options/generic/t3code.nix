# T3 Code: package (with optional extras), declarative settings and a server service
{
  flake.modules.generic.default = {
    config,
    lib,
    options,
    pkgs,
    username,
    ...
  }: let
    inherit (lib) concatMapAttrsStringSep escapeShellArg escapeShellArgs filterAttrs functionArgs genAttrs getExe' hasPrefix literalExpression makeBinPath mkEnableOption mkIf mkMerge mkOption mkOrder optional optionalAttrs;
    inherit (lib.types) attrsOf bool enum listOf nullOr package path port str;

    cfg = config.programs.t3code;
    svc = cfg.service;
    jsonFormat = pkgs.formats.json {};
    # Runtime secrets can't go through the Nix store, so install them on activation
    secretsScript = pkgs.writeShellScript "t3code-secrets" ''
      set -eu
      PATH=${makeBinPath [pkgs.coreutils]}

      # T3's secret store names files after the base64url source id
      ${concatMapAttrsStringSep "\n" (id: file: ''
          if [ -r ${file} ]; then
            (umask 077 && mkdir -p ${cfg.home}/userdata/secrets \
              && tr -d '\n' < ${file} > ${cfg.home}/userdata/secrets/usage-limit-source-$(printf %s ${escapeShellArg id} | basenc --base64url | tr -d =).bin)
          else
            echo "t3code: can't read usage limit secret ${file}" >&2
          fi
        '')
        cfg.usageLimitSecrets}
    '';
    # pkgs.stdenv.hostPlatform.is<Platform> causes infinite recursion so bodge
    isLinux = options ? systemd;
    isDarwin = options ? launchd;

    # Extras are the package's `enable*` override flags, e.g. extras.enableGitHub
    extraFlags = pkgs:
      functionArgs pkgs.t3code.override
      |> builtins.attrNames
      |> builtins.filter (hasPrefix "enable");
  in {
    options.programs.t3code = {
      enable = mkEnableOption "T3 Code, a GUI and server for coding agents";

      package = mkOption {
        type = nullOr package;
        default = pkgs.t3code.override (
          filterAttrs (_: enable: enable != null) cfg.extras
        );
        defaultText = literalExpression "pkgs.t3code.override programs.t3code.extras";
        description = ''
          T3 Code package to install. Defaults to `pkgs.t3code` overridden with
          {option}`programs.t3code.extras`. Null installs nothing (e.g. when the
          app comes from a Homebrew cask) while still managing settings.
        '';
      };

      extras = genAttrs (extraFlags pkgs) (flag:
        mkOption {
          type = nullOr bool;
          default = null;
          example = true;
          description = "Package override `${flag}`. Null keeps the package default.";
        });

      user = mkOption {
        type = str;
        default = username;
        defaultText = literalExpression "username";
        description = "User whose T3 Code settings are managed and who runs the server.";
      };

      home = mkOption {
        type = str;
        default = "${config.xdg.dirs.configDir}/t3";
        defaultText = literalExpression ''"''${config.xdg.dirs.configDir}/t3"'';
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

      desktopSettings = mkOption {
        inherit (jsonFormat) type;
        default = {};
        example = {localEnvironmentEnabled = false;};
        description = ''
          Desktop app settings applied to
          {file}`''${home}/userdata/desktop-settings.json`, like
          {option}`programs.t3code.settings`. Use this to stop the
          desktop app spawning its own backend (e.g.
          `localEnvironmentEnabled = false`) so it uses the
          background service instead.
        '';
      };

      usageLimitSecrets = mkOption {
        type = attrsOf str;
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
        type = enum ["merge" "seed"];
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
          type = str;
          default = "127.0.0.1";
          example = "0.0.0.0";
          description = "Address the server binds to.";
        };

        port = mkOption {
          type = port;
          default = 3773;
          description = "Port the server listens on.";
        };

        openFirewall = mkOption {
          type = bool;
          default = false;
          description = "Whether to open {option}`programs.t3code.service.port` in the firewall.";
        };

        workingDirectory = mkOption {
          type = str;
          default = config.users.users.${cfg.user}.home;
          defaultText = literalExpression "config.users.users.\${programs.t3code.user}.home";
          description = "Working directory of the server.";
        };

        environment = mkOption {
          type = attrsOf str;
          default = {};
          example = {FJ_FALLBACK_HOST = "https://git.example.com";};
          description = "Extra environment variables for the server.";
        };

        environmentFile = mkOption {
          type = nullOr path;
          default = null;
          example = "/run/secrets/t3code.env";
          description = "EnvironmentFile for the server, e.g. a sops-nix secret with API keys.";
        };

        extraArgs = mkOption {
          type = listOf str;
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
        environment.systemPackages = optional (cfg.package != null) cfg.package;
        mutableJson = {
          t3code-settings = mkIf (cfg.settings != {}) {
            inherit (cfg) user settings;
            path = "${cfg.home}/userdata/settings.json";
            mode = cfg.settingsMode;
          };
          t3code-client-settings = mkIf (cfg.uiSettings != {}) {
            inherit (cfg) user;
            path = "${cfg.home}/userdata/client-settings.json";
            settings = cfg.uiSettings;
            mode = cfg.settingsMode;
          };
          t3code-desktop-settings = mkIf (cfg.desktopSettings != {}) {
            inherit (cfg) user;
            path = "${cfg.home}/userdata/desktop-settings.json";
            settings = cfg.desktopSettings;
            mode = cfg.settingsMode;
          };
        };
      }

      (optionalAttrs isLinux {
        environment.sessionVariables.T3CODE_HOME = cfg.home;
        system.activationScripts.t3code-secrets = mkIf (cfg.usageLimitSecrets != {}) {
          # setupSecrets: sops-nix secrets referenced by usageLimitSecrets
          deps = ["users"] ++ optional (config.system.activationScripts ? setupSecrets) "setupSecrets";
          text = ''
            ${pkgs.util-linux}/bin/runuser -u ${cfg.user} -- ${secretsScript} \
              || echo "warning: failed to install t3code secrets" >&2
          '';
        };
        networking.firewall.allowedTCPPorts = mkIf (svc.enable && svc.openFirewall) [svc.port];
        systemd.services.t3code = mkIf svc.enable {
          description = "T3 Code server";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          # Activation runs before units restart, so this picks up merged settings
          restartTriggers = [secretsScript (builtins.hashString "sha256" (builtins.toJSON [cfg.settings cfg.uiSettings]))];
          environment = {T3CODE_HOME = cfg.home;} // svc.environment;
          serviceConfig = {
            User = cfg.user;
            WorkingDirectory = svc.workingDirectory;
            ExecStart = escapeShellArgs ([
                (getExe' cfg.package "t3")
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

      (optionalAttrs isDarwin {
        environment.variables.T3CODE_HOME = cfg.home;
        # After sops-nix's mkAfter secret install
        system.activationScripts.postActivation.text = mkIf (cfg.usageLimitSecrets != {}) (mkOrder 2000 ''
          /usr/bin/sudo -u ${cfg.user} ${secretsScript} \
            || echo "warning: failed to install t3code secrets" >&2
        '');
        launchd.user.agents.t3code-env = {
          command = "/bin/launchctl setenv T3CODE_HOME ${cfg.home}";
          serviceConfig.RunAtLoad = true;
        };
      })
    ]);
  };
}
