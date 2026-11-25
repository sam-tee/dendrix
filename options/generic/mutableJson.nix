{
  flake.modules.generic.default = {
    config,
    lib,
    options,
    pkgs,
    username,
    ...
  }: let
    inherit (lib) attrValues concatMapAttrsStringSep concatMapStringsSep groupBy literalExpression mapAttrs mkIf mkJsonMerge mkMerge mkOption mkOrder optionalAttrs platformFromOptions;
    inherit (lib.types) attrsOf enum str strMatching submodule;
    cfg = config.mutableJson;
    userScripts =
      groupBy (file: file.user) (attrValues cfg)
      |> mapAttrs (user: files:
        pkgs.writeShellScript "mutable-json-${user}" ''
          status=0
          ${concatMapStringsSep "\n" (file: "${mkJsonMerge pkgs file} || status=1")
            (map (file: removeAttrs file ["user"]) files)}
          exit $status
        '');
    runAs = runner:
      concatMapAttrsStringSep "\n" (user: script: ''
        ${runner user} ${script} \
          || echo "warning: failed to apply mutableJson files for ${user}" >&2
      '')
      userScripts;
    inherit (platformFromOptions options) isDarwin isLinux;
  in {
    options.mutableJson = mkOption {
      default = {};
      description = ''
        JSON files the owning app can rewrite, with declared settings merged in
        on every activation (or written once, with `mode = "seed"`), for apps
        that break on read-only hjem symlinks. See `lib.mkJsonMerge`.
      '';
      type = attrsOf (submodule ({name, ...}: {
        options = {
          user = mkOption {
            type = str;
            default = username;
            defaultText = literalExpression "username";
            description = "User that owns the file and runs the merge.";
          };
          path = mkOption {
            type = str;
            description = "Absolute path of the JSON file.";
          };
          settings = mkOption {
            inherit ((pkgs.formats.json {})) type;
            description = "Value merged into the file.";
          };
          mode = mkOption {
            type = enum ["merge" "seed"];
            default = "merge";
            description = ''
              `merge` applies {option}`operation` on every activation, so
              declared keys win and app-written keys are kept (keys later
              removed from Nix stay in the file). `seed` only writes missing
              or empty files.
            '';
          };
          operation = mkOption {
            type = str;
            default = "$current * $nix";
            example = "$current + $nix | unique_by(.key)";
            description = "jq expression combining `$current` (file) and `$nix` (settings).";
          };
          fileMode = mkOption {
            type = strMatching "[0-7]{3,4}";
            default = "600";
            description = "Permissions for a newly created file. Existing files keep theirs.";
          };
          name = mkOption {
            type = str;
            default = name;
            internal = true;
          };
        };
      }));
    };

    config = mkIf (cfg != {}) (mkMerge [
      (optionalAttrs isLinux {
        system.activationScripts.mutable-json = {
          deps = ["users"];
          text = runAs (user: "${pkgs.util-linux}/bin/runuser -u ${user} --");
        };
      })
      (optionalAttrs isDarwin {
        system.activationScripts.postActivation.text = mkOrder 2000 (runAs (user: "/usr/bin/sudo -u ${user}"));
      })
    ]);
  };
}
