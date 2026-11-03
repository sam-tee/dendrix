{
  lib,
  self,
  ...
}: let
  baseURL = "https://${self.services.cliproxyapi.fqdn}";
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
        environment.systemPackages = with pkgs; [
          claude-code
          opencode
        ];
        sops.secrets = lib.genAttrs [secret goSecret] (_: {owner = username;});
        environment.etc = {
          ${claudeFile}.source = json.generate "claude-managed-settings.json" {
            env = {
              ANTHROPIC_BASE_URL = baseURL;
              DISABLE_AUTOUPDATER = "1";
            };
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
