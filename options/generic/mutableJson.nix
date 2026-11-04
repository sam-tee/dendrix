# App-writable JSON files whose declared keys are merged in on activation
# (see lib.mkJsonMerge), for apps that break on read-only hjem symlinks
{lib, ...}: let
  inherit (lib) mkIf mkMerge mkOption types;
in {
  flake.modules.generic.default = {
    config,
    options,
    pkgs,
    username,
    ...
  }: let
    cfg = config.mutableJson;
    # Run each user's merges as that user; one failure doesn't stop the rest
    userScripts =
      lib.groupBy (file: file.user) (lib.attrValues cfg)
      |> lib.mapAttrs (user: files:
        pkgs.writeShellScript "mutable-json-${user}" ''
          status=0
          ${lib.concatMapStringsSep "\n" (file: "${lib.mkJsonMerge pkgs file} || status=1")
            (map (file: removeAttrs file ["user"]) files)}
          exit $status
        '');
    runAs = runner:
      lib.concatMapAttrsStringSep "\n" (user: script: ''
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
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          user = mkOption {
            type = types.str;
            default = username;
            defaultText = lib.literalExpression "username";
            description = "User that owns the file and runs the merge.";
          };
          path = mkOption {
            type = types.str;
            description = "Absolute path of the JSON file.";
          };
          settings = mkOption {
            inherit ((pkgs.formats.json {})) type;
            description = "Value merged into the file.";
          };
          mode = mkOption {
            type = types.enum ["merge" "seed"];
            default = "merge";
            description = ''
              `merge` applies {option}`operation` on every activation, so
              declared keys win and app-written keys are kept (keys later
              removed from Nix stay in the file). `seed` only writes missing
              or empty files.
            '';
          };
          operation = mkOption {
            type = types.str;
            default = "$current * $nix";
            example = "$current + $nix | unique_by(.key)";
            description = "jq expression combining `$current` (file) and `$nix` (settings).";
          };
          fileMode = mkOption {
            type = types.strMatching "[0-7]{3,4}";
            default = "600";
            description = "Permissions for a newly created file. Existing files keep theirs.";
          };
          name = mkOption {
            type = types.str;
            default = name;
            internal = true;
          };
        };
      }));
    };

    config = mkIf (cfg != {}) (mkMerge [
      (lib.optionalAttrs isLinux {
        system.activationScripts.mutable-json = {
          deps = ["users"];
          text = runAs (user: "${pkgs.util-linux}/bin/runuser -u ${user} --");
        };
      })
      (lib.optionalAttrs isDarwin {
        system.activationScripts.postActivation.text = lib.mkOrder 2000 (runAs (user: "/usr/bin/sudo -u ${user}"));
      })
    ]);
  };
}
