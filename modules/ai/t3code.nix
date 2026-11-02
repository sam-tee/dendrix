{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  inherit (self.services) cliproxyapi;
  inherit (self.services.t3) port;
  inherit (self.cosmetic) fonts;

  usageSourceId = "cliproxy-${cliproxyapi.fqdn}";

  serverSettings = {
    favorites = [
      {
        provider = "claudeAgent";
        model = "claude-opus-5-5";
      }
      {
        provider = "claudeAgent";
        model = "claude-haiku-5-5";
      }
      {
        provider = "opencode";
        model = "opencode-go/muse-spark-1.3-contributer";
      }
      {
        provider = "opencode";
        model = "opencode-go/deepseek-v4.1-flash";
      }
      {
        provider = "opencode";
        model = "opencode/mimo-v2.6-flash-free";
      }
    ];
    defaultModelSelection = {
      instanceId = "claudeAgent";
      model = "claude-opus-5-5";
      options = [
        {
          id = "effort";
          value = "high";
        }
      ];
    };
    defaultAutoPull = true;
    enableProviderUpdateChecks = false;
    enableAgentDeviceAccess = true;
    enableDeviceSupport = true;
    deviceOnboardingCompleted = true;
    idleCompaction = "onReturn";
    snoozeLimitedThreads = true;
    autoResumeLimitedThreads = true;
    addProjectBaseDirectory = "~/Projects";
    storageCleanup = {
      worktreeAfterDays = 8;
      worktreeOnMerge = true;
      worktreeOnDelete = true;
      worktreeUnchanged = true;
      browserArtifactsAfterDays = 8;
    };
    providerInstances = {
      claudeAgent = {
        driver = "claudeAgent";
        enabled = true;
        config.binaryPath = "claude";
      };
      codex = {
        driver = "codex";
        enabled = false;
        config.binaryPath = "codex";
      };
      opencode = {
        driver = "opencode";
        enabled = true;
        config.binaryPath = "opencode2";
      };
    };
    usageLimitSources.${usageSourceId} = {
      kind = "cliproxy";
      label = cliproxyapi.host;
      url = "https://${cliproxyapi.fqdn}";
      managementKey = "••••••";
      enabled = true;
    };
  };

  clientSettings = {
    notificationMode = "notifications";
    inAppNotificationsEnabled = true;
    followUpBehavior = "queue";
    fontFamilyCode = fonts.mono.name;
    fontFamilyTerminal = fonts.mono.name;
    fontFamilySans = fonts.ui.name;
    fontSizeCode = 14;
    fontSizeTerminal = 14;
  };

  mkScript = {
    config,
    pkgs,
  }: name: body:
    pkgs.writeShellScript "t3code-${name}" ''
      set -eu
      PATH=${lib.makeBinPath [pkgs.coreutils pkgs.jq]}
      mkdir -p ${config.xdg.dirs.configDir}/t3/userdata
      cd ${config.xdg.dirs.configDir}/t3/userdata
      ${body}
    '';
  mergeJson = pkgs: file: settings: ''
    [ -s ${file} ] || echo '{}' > ${file}
    tmp=$(mktemp ${file}.XXXXXX)
    jq --slurpfile d ${(pkgs.formats.json {}).generate "t3code-${file}" settings} \
      '. * $d[0]' ${file} > "$tmp" || { rm -f "$tmp"; exit 1; }
    mv "$tmp" ${file}
  '';

  serverScript = {
    config,
    pkgs,
  }: let
    keyFile = config.sops.secrets.cliproxyapi-key.path;
  in
    mkScript {inherit config pkgs;} "settings" ''
      ${mergeJson pkgs "settings.json" serverSettings}
      # The client key doubles as cliproxyapi's management key. Write it to
      # t3's secret store directly so it never sits in settings.json.
      if [ -r ${keyFile} ]; then
        name=usage-limit-source-$(printf %s ${usageSourceId} | basenc --base64url | tr -d =)
        (umask 077 && mkdir -p secrets && tr -d '\n' < ${keyFile} > "secrets/$name.bin")
      fi
    '';
  clientScript = {
    config,
    pkgs,
  }:
    mkScript {inherit config pkgs;} "client-settings"
    (mergeJson pkgs "client-settings.json" clientSettings);
in {
  flake.modules = {
    nixos = {
      default = self.modules.nixos.t3;
      t3desktop = moduleWithSystem ({self', ...}: {
        config,
        pkgs,
        ...
      }: {
        environment = {
          sessionVariables.T3CODE_HOME = "${config.xdg.dirs.configDir}/t3";
          systemPackages = [self'.packages.t3code-desktop-slim];
        };
        systemd.services.t3code.serviceConfig.ExecStartPre = [
          "-${clientScript {inherit config pkgs;}}"
        ];
      });
      t3 = {
        key = "dendrix#nixos.t3";
        imports = [
          (moduleWithSystem ({self', ...}: {
            config,
            pkgs,
            username,
            ...
          }: let
            t3 = self'.packages.t3code-slim;
            inherit (config.users.users.${username}) home;
            inherit (self.hosts.${config.networking.hostName}) tailscaleIP;
          in {
            environment = {
              sessionVariables.T3CODE_HOME = "${config.xdg.dirs.configDir}/t3";
              systemPackages = [t3];
            };
            systemd.services.t3code = {
              description = "T3 Code server (tailscale-bound, nightly)";
              after = ["network-online.target" "tailscaled.service"];
              wants = ["network-online.target"];
              wantedBy = ["multi-user.target"];
              environment = {
                T3CODE_HOME = "${config.xdg.dirs.configDir}/t3";
                FJ_FALLBACK_HOST = "https://${self.services.forgejo.fqdn}";
                NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
                NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
              };
              serviceConfig = {
                User = username;
                WorkingDirectory = home;
                ExecStartPre = ["-${serverScript {inherit config pkgs;}}"];
                ExecStart = "${lib.getExe t3} serve --host ${tailscaleIP} --port ${toString port}";
                Restart = "always";
                RestartSec = 10;
              };
            };
          }))
        ];
      };
    };

    darwin = {
      default = self.modules.darwin.t3;
      t3 = {
        config,
        pkgs,
        username,
        ...
      }: let
        t3Home = "${config.xdg.dirs.configDir}/t3";
      in {
        homebrew.casks = ["t3-code"];
        environment.variables.T3CODE_HOME = t3Home;
        launchd.user.agents.t3code-env = {
          command = "/bin/launchctl setenv T3CODE_HOME ${t3Home}";
          serviceConfig.RunAtLoad = true;
        };
        system.activationScripts.postActivation.text = lib.concatMapStrings (script: ''
          /usr/bin/sudo -u ${username} ${script {inherit config pkgs;}} \
            || echo "warning: failed to apply t3code settings" >&2
        '') [serverScript clientScript];
      };
    };
  };
}
