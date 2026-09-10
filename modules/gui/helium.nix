{
  moduleWithSystem,
  self,
  ...
}: {
  flake-file.inputs.helium = {
    url = "github:amaanq/helium-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules = {
    darwin.default = self.modules.generic.helium;
    nixos.gui = self.modules.nixos.helium;
    generic.helium = moduleWithSystem ({inputs', ...}: _: {
      environment.systemPackages = [inputs'.helium.packages.default];
      hjem.extraModules = [self.modules.hjem.helium];
    });
    nixos.helium = {
      imports = [self.modules.generic.helium];
      programs.chromium = {
        enable = true;
        extensions = [
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          "ekhagklcjbdpajgpjgmbionohlpdbjgc"
          "jplgfhpmjnbigmhklmmbgecoobifkmpa"
          "mbhadeogepkjdjeikcckdkjdjhhkhlid"
          "mnjggcdmjocbbbhaepdhchncahnbgone"
          "nffaoalbilbmmfgbnbgppjihopabppdk"
          "nngceckbapebfimnlniiiahkandclblb"
          "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
          "pnidmkljnhbjfffciajlcpeldoljnidn"
        ];
      };
    };
    hjem.helium = {
      lib,
      pkgs,
      ...
    }: let
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      preferences = {
        helium = {
          completed_onboarding = true;
          services.user_consented = true;
          browser = {
            centered_location_bar = true;
            layout = 2;
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
