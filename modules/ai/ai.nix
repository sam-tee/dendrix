{self, ...}: let
  svc = self.services.cliproxyapi;
  baseURL = "http://${svc.host}.${self.tailnet}:${toString svc.port}";
  secret = "cliproxyapi-key";
  goSecret = "opencode-go-key";
  claudeFile = "claude-code/managed-settings.d/dendrix.json";
  opencodeFile = "opencode/opencode.json";
in {
  flake.modules = {
    generic = {
      default = self.modules.generic.ai;
      ai = {
        config,
        lib,
        pkgs,
        username,
        ...
      }: let
        keyFile = config.sops.secrets.${secret}.path;
        goKeyFile = config.sops.secrets.${goSecret}.path;
        cat = "${pkgs.coreutils}/bin/cat";
        json = pkgs.formats.json {};
        toml = pkgs.formats.toml {};
      in {
        # TEMPORARY: nixpkgs' opencode node_modules hash is wrong; remove this
        # overlay once upstream is fixed, or it will cause hash mismatches on a
        # later nixpkgs bump. aarch64-linux reuses the Linux hash (unverified).
        nixpkgs.overlays = [
          (_: prev: {
            opencode = prev.opencode.overrideAttrs (old: {
              node_modules = old.node_modules.overrideAttrs {
                outputHash =
                  if prev.stdenv.hostPlatform.isDarwin
                  then "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc="
                  else "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
              };
            });
          })
        ];
        # claude-code, codex and opencode come from programs.t3code.extras
        sops.secrets = lib.genAttrs [secret goSecret] (_: {owner = username;});
        environment.etc = {
          ${claudeFile}.source = json.generate "claude-managed-settings.json" {
            env = {
              ANTHROPIC_BASE_URL = baseURL;
              DISABLE_AUTOUPDATER = "1";
            };
            promptCacheTtl = "1h";
            apiKeyHelper = "${cat} ${keyFile}";
            permissions.defaultMode = "auto";
            theme = "dark-ansi";
            autoMemoryEnabled = false;
            switchModelsOnFlag = false;
            pluginConfigs."cc-plugin-agents-md@builtin".options.instructionFiles = "claude-md-or-agents-md";
          };
          ${opencodeFile}.source = json.generate "opencode.json" {
            "$schema" = "https://opencode.ai/config.json";
            autoupdate = false;
            provider.opencode-go.options.apiKey = "{file:${goKeyFile}}";
          };
          "codex/config.toml".source = toml.generate "codex-config.toml" {
            check_for_update_on_startup = false;
            model_provider = "cliproxyapi";
            model_providers.cliproxyapi = {
              name = "CLIProxyAPI";
              base_url = "${baseURL}/v1";
              wire_api = "responses";
              requires_openai_auth = false;
              supports_websockets = true;
              auth = {
                command = cat;
                args = [keyFile];
              };
            };
          };
        };
      };
    };

    darwin = {
      default = self.modules.darwin.ai;
      ai = let
        claudeDir = "/Library/Application Support/ClaudeCode/managed-settings.d";
        opencodeDir = "/Library/Application Support/opencode";
      in {
        system.activationScripts.postActivation.text = ''
          mkdir -p "${claudeDir}" "${opencodeDir}"
          install -m 644 /etc/${claudeFile} "${claudeDir}/dendrix.json"
          ln -sfn /etc/${opencodeFile} "${opencodeDir}/opencode.json"
        '';
      };
    };
  };
}
