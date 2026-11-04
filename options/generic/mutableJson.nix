# App-writable JSON files whose declared keys are merged in on activation
# (see lib.mkJsonMerge), for apps that break on read-only hjem symlinks
{
  flake.modules.generic.default = {
    config,
    lib,
    options,
    pkgs,
    username,
    ...
  }: let
    inherit (lib) attrValues concatMapAttrsStringSep concatMapStringsSep groupBy literalExpression mapAttrs mkIf mkJsonMerge mkMerge mkOption mkOrder optionalAttrs;
    inherit (lib.types) attrsOf enum str strMatching submodule;
    cfg = config.mutableJson;
    # Run each user's merges as that user; one failure doesn't stop the rest
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
    # pkgs.stdenv.hostPlatform.is<Platform> causes infinite recursion so bodge
    isLinux = options ? systemd;
    isDarwin = options ? launchd;
  in {
    options.mutableJson = mkOption {
      default = {};
      description = ''
        JSON files the owning app can rewrite, with declared settings merged in
        on every activation (or written once, with `mode = "seed"`).
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
