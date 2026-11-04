{self, ...}: let
  inherit (self.services) cliproxyapi;
  inherit (self.services.t3) port;
  inherit (self.cosmetic) fonts;
  cliproxySource = "cliproxy-${cliproxyapi.fqdn}";
in {
  flake.modules = {
    nixos = {
      default = self.modules.nixos.t3;
      t3 = {config, ...}: {
        programs.t3code = {
          service = {
            enable = true;
            host = self.hosts.${config.networking.hostName}.tailscaleIP;
            inherit port;
            environment = {
              FJ_FALLBACK_HOST = "https://${self.services.forgejo.fqdn}";
              NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
              NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
            };
          };
          desktopSettings.localEnvironmentEnabled = false;
        };
        systemd.services.t3code.after = ["tailscaled.service"];
      };
    };

    generic = {
      default = self.modules.generic.t3code;
      t3code = {config, ...}: {
        programs.t3code = {
          enable = true;
          usageLimitSecrets.${cliproxySource} = config.sops.secrets.cliproxyapi-key.path;
          extras = {
            enableClaude = true;
            enableCodex = false;
            enableOpencode = true;
            enableGit = true;
            enableGitHub = true;
          };
          uiSettings = {
            notificationMode = "notifications";
            inAppNotificationsEnabled = true;
            fontFamilyCode = fonts.mono.name;
            fontFamilyTerminal = fonts.mono.name;
            fontFamilySans = fonts.ui.name;
            fontSizeCode = 14;
            fontSizeTerminal = 14;
          };
          settings = {
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
                config.binaryPath = "opencode";
              };
            };
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
                model = "opencode-go/muse-spark-1.3-contributor";
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
            textGenerationModelSelection = {
              instanceId = "claudeAgent";
              model = "claude-haiku-5-5";
            };
            usageLimitSources.${cliproxySource} = {
              kind = "cliproxy";
              label = cliproxyapi.host;
              url = "https://${cliproxyapi.fqdn}";
              managementKey = "••••••";
              enabled = true;
            };
            # Opencode doesn't report model pricing correctly so workaround
            usagePriceOverrides = {
              "muse-spark-1.3-contributor" = {
                inputCostPerMillionTokens = 0.1;
                outputCostPerMillionTokens = 0.2;
                cacheReadCostPerMillionTokens = 0.002;
              };
              "deepseek-v4.1-flash" = {
                inputCostPerMillionTokens = 0.15;
                outputCostPerMillionTokens = 0.6;
                cacheReadCostPerMillionTokens = 0.003;
              };
            };
          };
        };
      };
    };
  };
}
