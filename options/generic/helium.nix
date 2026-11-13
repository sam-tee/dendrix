# Helium browser: package, managed policies, extensions and default profile preferences
{moduleWithSystem, ...}: {
  flake.modules.generic.default = moduleWithSystem ({inputs', ...}: {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapAttrs concatMapAttrsStringSep filterAttrs genAttrs generators literalExpression mapAttrs mapAttrsToList mkEnableOption mkIf mkMerge mkOption mkOrder optionalAttrs;
    inherit (lib.types) attrsOf bool package str submodule;

    cfg = config.programs.helium;
    jsonFormat = pkgs.formats.json {};
    # pkgs.stdenv.hostPlatform.is<Platform> causes infinite recursion so bodge
    isLinux = options ? systemd;
    isDarwin = options ? launchd;

    # Extensions not preinstalled in Helium are force-installed by policy
    forcelist =
      cfg.extensions
      |> filterAttrs (_: extension: !extension.preinstalled)
      |> mapAttrsToList (_: extension: extension.id);
    extensionSettings =
      cfg.extensions
      |> concatMapAttrs (_: extension:
        optionalAttrs (extension.settings != {}) {${extension.id} = extension.settings;});
    thirdParty =
      cfg.extensions
      |> concatMapAttrs (_: extension:
        optionalAttrs (extension.policy != {}) {${extension.id} = extension.policy;});
    managedPolicies =
      cfg.policies
      // optionalAttrs (extensionSettings != {}) {ExtensionSettings = extensionSettings;}
      // optionalAttrs (thirdParty != {}) {"3rdparty".extensions = thirdParty;};

    toManagedPlist = name: value: pkgs.writeText "${name}.plist" (generators.toPlist {escape = true;} value);
    managedPrefs = "/Library/Managed Preferences";
    darwinPolicyFiles =
      {"net.imput.helium" = managedPolicies // {ExtensionInstallForcelist = forcelist;};}
      // (thirdParty |> concatMapAttrs (id: policy: {"net.imput.helium.extensions.${id}" = policy;}));

    preferenceFile = {
      generator = generators.toJSON {};
      value = cfg.preferences;
      type = "copy";
    };
    mimeTypes = [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
      "application/pdf"
    ];
  in {
    options.programs.helium = {
      enable = mkEnableOption "Helium, a privacy-focused Chromium-based browser";

      package = mkOption {
        type = package;
        default = inputs'.helium.packages.default;
        defaultText = literalExpression "inputs'.helium.packages.default";
        description = "Helium package to install.";
      };

      defaultBrowser = mkOption {
        type = bool;
        default = true;
        description = "Whether to register Helium as the default browser and PDF viewer (Linux only).";
      };

      extensions = mkOption {
        default = {};
        description = "Chrome Web Store extensions to install and configure, keyed by a descriptive name.";
        example = literalExpression ''
          {
            ublock-origin = {
              id = "blockjmkbacgjkknlgpkjjiijinjdanf";
              preinstalled = true;
              settings.toolbar_pin = "force_pinned";
            };
          }
        '';
        type = attrsOf (submodule {
          options = {
            id = mkOption {
              type = str;
              description = "Chrome Web Store extension ID.";
            };
            preinstalled = mkOption {
              type = bool;
              default = false;
              description = "Whether Helium already bundles the extension, so it isn't force-installed.";
            };
            settings = mkOption {
              inherit (jsonFormat) type;
              default = {};
              description = "Entry for the extension in the `ExtensionSettings` policy.";
            };
            policy = mkOption {
              inherit (jsonFormat) type;
              default = {};
              description = "Managed storage policy (`3rdparty.extensions`) for the extension.";
            };
          };
        });
      };

      policies = mkOption {
        inherit (jsonFormat) type;
        default = {};
        example = {NewTabPageLocation = "https://example.com";};
        description = ''
          Extra Chromium enterprise policies. Extension policies are generated
          from {option}`programs.helium.extensions`.
        '';
      };

      preferences = mkOption {
        inherit (jsonFormat) type;
        default = {};
        description = "Contents of the default profile's `Preferences` file, copied on activation.";
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        environment.systemPackages = [cfg.package];
        hjem.extraModules = mkIf (cfg.preferences != {}) [
          (
            if isLinux
            then {xdg.config.files."net.imput.helium/Default/Preferences" = preferenceFile;}
            else {files."Library/Application Support/net.imput.helium/Default/Preferences" = preferenceFile;}
          )
        ];
      }

      (optionalAttrs isLinux {
        xdg.mime.defaultApplications = mkIf cfg.defaultBrowser (genAttrs mimeTypes (_: "helium.desktop"));
        # Helium reads Chromium's managed policy directory
        programs.chromium = {
          enable = true;
          extensions = forcelist;
          extraOpts = managedPolicies;
        };
      })

      (optionalAttrs isDarwin {
        # Custom activation script names aren't run by nix-darwin
        system.activationScripts.postActivation.text = mkOrder 1500 ''
          mkdir -p "${managedPrefs}"
          ${darwinPolicyFiles
            |> mapAttrs toManagedPlist
            |> concatMapAttrsStringSep "\n" (name: file: ''cp ${file} "${managedPrefs}/${name}.plist"'')}
        '';
      })
    ]);
  });
}
