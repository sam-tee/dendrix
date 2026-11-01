{
  lib,
  self,
  ...
}: let
  baseURL = "https://${self.services.cliproxyapi.fqdn}";
  secret = "cliproxyapi-key";
  goSecret = "opencode-go-key";

  clientFiles = {
    config,
    pkgs,
  }: let
    keyFile = config.sops.secrets.${secret}.path;
    goKeyFile = config.sops.secrets.${goSecret}.path;
    cat = "${pkgs.coreutils}/bin/cat";
    json = pkgs.formats.json {};
    toml = pkgs.formats.toml {};
  in {
    claude = json.generate "claude-cliproxyapi.json" {
      env.ANTHROPIC_BASE_URL = baseURL;
      apiKeyHelper = "${cat} ${keyFile}";
    };
    opencode = json.generate "opencode.json" {
      "$schema" = "https://opencode.ai/config.json";
      provider.opencode-go.options.apiKey = "{file:${goKeyFile}}";
    };
    codex = toml.generate "codex-config.toml" {
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
in {
  flake.modules = {
    generic = {
      default = self.modules.generic.cliproxyClient;
      cliproxyClient = {
        config,
        pkgs,
        username,
        ...
      }: {
        sops.secrets = lib.genAttrs [secret goSecret] (_: {owner = username;});
        # System layer: ~/.codex/config.toml still overrides it.
        environment.etc."codex/config.toml".source = (clientFiles {inherit config pkgs;}).codex;
      };
    };

    # Managed (system-level) configs, so user-editable settings stay untouched.
    nixos.default = {
      config,
      pkgs,
      ...
    }: let
      files = clientFiles {inherit config pkgs;};
    in {
      environment.etc = {
        "claude-code/managed-settings.d/cliproxyapi.json".source = files.claude;
        "opencode/opencode.json".source = files.opencode;
      };
    };

    darwin.default = {
      config,
      pkgs,
      ...
    }: let
      files = clientFiles {inherit config pkgs;};
      claudeDir = "/Library/Application Support/ClaudeCode/managed-settings.d";
      opencodeDir = "/Library/Application Support/opencode";
    in {
      system.activationScripts.postActivation.text = ''
        mkdir -p "${claudeDir}" "${opencodeDir}"
        cp ${files.claude} "${claudeDir}/cliproxyapi.json"
        cp ${files.opencode} "${opencodeDir}/opencode.json"
        chmod 644 "${claudeDir}/cliproxyapi.json" "${opencodeDir}/opencode.json"
      '';
    };
  };
}
