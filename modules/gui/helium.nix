{
  moduleWithSystem,
  self,
  lib,
  ...
}: let
  inherit (lib.attrsets) concatMapAttrs filterAttrs mapAttrsToList optionalAttrs getAttr;
  inherit (lib.trivial) const;

  vscKeyBindings = [
    {
      action = "slower";
      code = "KeyS";
      key = 83;
      keyCode = 83;
      displayKey = "s";
      value = 0.5;
      predefined = true;
    }
    {
      action = "faster";
      code = "KeyD";
      key = 68;
      keyCode = 68;
      displayKey = "d";
      value = 0.5;
      predefined = true;
    }
    {
      action = "fast";
      code = "KeyG";
      key = 71;
      keyCode = 71;
      displayKey = "g";
      value = 3.0;
      predefined = true;
    }
  ];

  extensions = {
    ublock-origin = {
      id = "blockjmkbacgjkknlgpkjjiijinjdanf";
      preinstalled = true;
      settings.toolbar_pin = "force_pinned";
    };
    dark-reader = {
      id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
      settings.toolbar_pin = "force_pinned";
    };
    bitwarden = {
      id = "nngceckbapebfimnlniiiahkandclblb";
      settings.toolbar_pin = "force_pinned";
    };
    zotero-connector.id = "ekhagklcjbdpajgpjgmbionohlpdbjgc";
    proton-vpn.id = "jplgfhpmjnbigmhklmmbgecoobifkmpa";
    trakt-scrobbler.id = "mbhadeogepkjdjeikcckdkjdjhhkhlid";
    sponsorblock.id = "mnjggcdmjocbbbhaepdhchncahnbgone";
    video-speed-controller = {
      id = "nffaoalbilbmmfgbnbgppjihopabppdk";
      policy = {
        startHidden = true;
        keyBindings = vscKeyBindings;
      };
    };
    privacy-badger.id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp";
    linkwarden.id = "pnidmkljnhbjfffciajlcpeldoljnidn";
  };

  forcelist =
    extensions
    |> filterAttrs (_: extension: !(extension.preinstalled or false))
    |> mapAttrsToList (const <| getAttr "id");

  extensionSettings =
    extensions
    |> concatMapAttrs (
      _: extension: optionalAttrs (extension ? settings) {${extension.id} = extension.settings;}
    );

  thirdParty =
    extensions
    |> concatMapAttrs (
      _: extension: optionalAttrs (extension ? policy) {${extension.id} = extension.policy;}
    );

  policy = {
    ExtensionInstallForcelist = forcelist;
    ExtensionSettings = extensionSettings;
    "3rdparty".extensions = thirdParty;
  };
in {
  flake-file.inputs.helium = {
    url = "github:amaanq/helium-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules = {
    darwin.default = {
      imports = [self.modules.generic.helium self.modules.darwin.helium];
    };
    nixos.gui = self.modules.nixos.helium;
    generic.helium = moduleWithSystem ({inputs', ...}: _: {
      environment.systemPackages = [inputs'.helium.packages.default];
      hjem.extraModules = [self.modules.hjem.helium];
    });
    nixos.helium = {
      imports = [self.modules.generic.helium];
      programs.chromium = {
        enable = true;
        extensions = forcelist;
        extraOpts = {
          ExtensionSettings = extensionSettings;
          "3rdparty".extensions = thirdParty;
        };
      };
    };
    darwin.helium = {
      lib,
      pkgs,
      ...
    }: {
      imports = [self.modules.generic.helium];
      system.activationScripts.helium-policy.text = let
        heliumPlist = pkgs.writeText "net.imput.helium.plist" (lib.generators.toPlist {escape = true;} policy);
        extensionPlists = lib.mapAttrs' (id: extensionPolicy: lib.nameValuePair id (pkgs.writeText "net.imput.helium.extensions.${id}.plist" (lib.generators.toPlist {escape = true;} extensionPolicy))) thirdParty;
      in ''
        mkdir -p "/Library/Managed Preferences"
        cp ${heliumPlist} "/Library/Managed Preferences/net.imput.helium.plist"
        ${extensionPlists |> lib.mapAttrsToList (id: file: ''cp ${file} "/Library/Managed Preferences/net.imput.helium.extensions.${id}.plist"'') |> lib.concatStringsSep "\n"}
      '';
    };
    hjem.helium = {
      lib,
      osConfig,
      pkgs,
      ...
    }: let
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      preferences = {
        helium = {
          completed_onboarding = true;
          services = {
            schema_version = 1;
            user_consented = true;
          };
          browser = {
            centered_location_bar = true;
            layout =
              # massive hack but oh well
              if osConfig.networking.hostName == "duet"
              then 3
              else 2;
            minimal_location_bar = false;
            rounded_frame = false;
            vertical_right_aligned = true;
            zen_mode = false;
            zen_mode_sidebar_pinned = true;
            zen_mode_top_chrome_pinned = true;
          };
        };
        browser.theme.is_grayscale2 = true;
        intl.selected_languages = "en-GB,en-US,en";
        spellcheck.dictionaries = ["en-GB"];
        vertical_tabs = {
          collapsed_state = true;
          uncollapsed_width = 200;
        };
        privacy_sandbox.first_party_sets_enabled = false;
      };
      preferenceFile = {
        generator = lib.generators.toJSON {};
        value = preferences;
        type = "copy";
      };
    in {
      xdg.config.files."net.imput.helium/Default/Preferences" = lib.mkIf isLinux preferenceFile;
      files."Library/Application Support/net.imput.helium/Default/Preferences" = lib.mkIf (!isLinux) preferenceFile;
    };
  };
}
