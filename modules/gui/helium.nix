{self, ...}: let
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
in {
  flake.modules = {
    darwin.default = self.modules.generic.helium;
    nixos = {
      gui = self.modules.nixos.helium;
      helium = self.modules.generic.helium;
    };
    generic.helium = {config, ...}: {
      programs.helium = {
        enable = true;
        policies.NewTabPageLocation = "https://${self.services.site.fqdn}";
        extensions = {
          ublock-origin = {
            id = "blockjmkbacgjkknlgpkjjiijinjdanf";
            preinstalled = true;
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
                if (config.mobile.enable or false)
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
      };
    };
  };
}
