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
    mkSettingsFile = file: value:
      mkIf (value != {}) {
        target = "userdata/${file}";
        relativeTo = cfg.home;
        source = jsonFormat.generate "t3code-${file}" value;
      };
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
          Server settings written to {file}`''${home}/userdata/settings.json`.
          Empty leaves the file app-managed; a declared file is a read-only
          Nix-store symlink, so saving settings from the UI fails while set.
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
          Desktop/client settings written to
          {file}`''${home}/userdata/client-settings.json`, with the same
          read-only caveat as {option}`programs.t3code.settings`.
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
        hjem.users.${cfg.user}.files = {
          t3code-settings = mkSettingsFile "settings.json" cfg.settings;
          t3code-client-settings = mkSettingsFile "client-settings.json" cfg.uiSettings;
        };
      }

      (lib.optionalAttrs isLinux {
        environment.sessionVariables.T3CODE_HOME = cfg.home;
        networking.firewall.allowedTCPPorts = mkIf (svc.enable && svc.openFirewall) [svc.port];
        systemd.services.t3code = mkIf svc.enable {
          description = "T3 Code server";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
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
        launchd.user.agents.t3code-env = {
          command = "/bin/launchctl setenv T3CODE_HOME ${cfg.home}";
          serviceConfig.RunAtLoad = true;
        };
      })
    ]);
  };
}
