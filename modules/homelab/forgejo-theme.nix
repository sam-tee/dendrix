{self, ...}: let
  inherit (self.cosmetic) fonts theme;
  inherit (theme) attrs;
in {
  flake.modules.nixos.forgejo-theme = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
    cssDir = "${cfg.customDir}/public/assets/css";
    # Full standalone theme CSS generated from the repo base16 palette
    # (theme/theme.toml). Modelled on the upstream forgejo-dark/light
    # variable set so no variables fall back to defaults.
    mkThemeCss = variant: let
      c = attrs.${variant};
      isDark = variant == "dark";
    in
      with c; ''
        ${
          if isDark
          then ''
            .markup [src$="#gh-light-mode-only"],
            .markup [src$="#light-mode-only"],
            .markup [href$="#gh-light-mode-only"],
            .markup [href$="#light-mode-only"] {
              display: none;
            }

            .markup [src$="#gh-dark-mode-only"],
            .markup [src$="#dark-mode-only"],
            .markup [href$="#gh-dark-mode-only"],
            .markup [href$="#dark-mode-only"] {
              display: unset;
            }
          ''
          else ''
            .markup [src$="#gh-dark-mode-only"],
            .markup [src$="#dark-mode-only"],
            .markup [href$="#gh-dark-mode-only"],
            .markup [href$="#dark-mode-only"] {
              display: none;
            }

            .markup [src$="#gh-light-mode-only"],
            .markup [src$="#light-mode-only"],
            .markup [href$="#gh-light-mode-only"],
            .markup [href$="#light-mode-only"] {
              display: unset;
            }
          ''
        }

        :root {
          --fonts-proportional: '${fonts.ui.name}', system-ui, sans-serif !important;
          --fonts-monospace: '${fonts.mono.name}', ui-monospace, monospace !important;

          --steel-900: ${base00};
          --steel-850: ${base00};
          --steel-800: ${base00};
          --steel-750: ${base01};
          --steel-700: ${base01};
          --steel-650: ${base02};
          --steel-600: ${base02};
          --steel-550: ${base03};
          --steel-500: ${base03};
          --steel-450: ${base04};
          --steel-400: ${base04};
          --steel-350: ${base04};
          --steel-300: ${base05};
          --steel-250: ${base05};
          --steel-200: ${base05};
          --steel-150: ${base06};
          --steel-100: ${base06};
          ${
          if isDark
          then "--is-dark-theme: true;"
          else ""
        }
          --color-primary: ${base0D};
          --color-primary-contrast: #000;
          --color-primary-dark-1: ${base0D};
          --color-primary-dark-2: ${base0D};
          --color-primary-dark-3: ${base0D};
          --color-primary-dark-4: ${base0D};
          --color-primary-light-1: ${base0C};
          --color-primary-light-2: ${base0D};
          --color-primary-light-3: ${base0D};
          --color-primary-light-4: ${base0D};
          --color-primary-light-5: ${base0D};
          --color-primary-light-6: ${base0D};
          --color-primary-light-7: ${base0D};
          --color-primary-alpha-10: ${base0D}19;
          --color-primary-alpha-20: ${base0D}33;
          --color-primary-alpha-30: ${base0D}4b;
          --color-primary-alpha-40: ${base0D}66;
          --color-primary-alpha-50: ${base0D}80;
          --color-primary-alpha-60: ${base0D}99;
          --color-primary-alpha-70: ${base0D}b3;
          --color-primary-alpha-80: ${base0D}cc;
          --color-primary-alpha-90: ${base0D}e1;
          --color-primary-hover: var(--color-primary-light-1);
          --color-primary-active: ${base0E};
          --color-secondary: ${base02};
          --color-secondary-dark-1: ${base02};
          --color-secondary-dark-2: ${base02};
          --color-secondary-dark-3: ${base03};
          --color-secondary-dark-4: ${base03};
          --color-secondary-dark-5: ${base04};
          --color-secondary-dark-6: ${base04};
          --color-secondary-dark-7: ${base05};
          --color-secondary-dark-8: ${base05};
          --color-secondary-dark-9: ${base06};
          --color-secondary-dark-10: ${base06};
          --color-secondary-dark-11: ${base07};
          --color-secondary-dark-12: ${base07};
          --color-secondary-dark-13: ${base07};
          --color-secondary-light-1: ${base02};
          --color-secondary-light-2: ${base01};
          --color-secondary-light-3: ${base01};
          --color-secondary-light-4: ${base00};
          --color-secondary-alpha-10: ${base02}19;
          --color-secondary-alpha-20: ${base02}33;
          --color-secondary-alpha-30: ${base02}4b;
          --color-secondary-alpha-40: ${base02}66;
          --color-secondary-alpha-50: ${base02}80;
          --color-secondary-alpha-60: ${base02}99;
          --color-secondary-alpha-70: ${base02}b3;
          --color-secondary-alpha-80: ${base02}cc;
          --color-secondary-alpha-90: ${base02}e1;
          --color-secondary-hover: var(--color-secondary-light-1);
          --color-secondary-active: var(--color-secondary-light-2);
          /* console colors - used for actions console and console files */
          --color-console-fg: ${base05};
          --color-console-fg-subtle: ${base04};
          --color-console-bg: ${base00};
          --color-console-border: ${base02};
          --color-console-hover-bg: ${base05}16;
          --color-console-active-bg: ${base02};
          --color-console-menu-bg: ${base01};
          --color-console-menu-border: ${base03};
          /* colors */
          --color-red: ${base08};
          --color-orange: ${base09};
          --color-yellow: ${base0A};
          --color-olive: ${base0B};
          --color-green: ${base0B};
          --color-teal: ${base0C};
          --color-blue: ${base0D};
          --color-violet: ${base0E};
          --color-purple: ${base0E};
          --color-pink: ${base0F};
          --color-brown: ${base09};
          --color-grey: ${base03};
          --color-black: ${base00};
          /* light variants */
          --color-red-light: ${base08};
          --color-orange-light: ${base09};
          --color-yellow-light: ${base0A};
          --color-olive-light: ${base0B};
          --color-green-light: ${base0B};
          --color-teal-light: ${base0C};
          --color-purple-light: ${base0E};
          --color-pink-light: ${base0F};
          --color-brown-light: ${base09};
          --color-grey-light: ${base04};
          --color-black-light: ${base01};
          /* dark 1 variants */
          --color-red-dark-1: ${base08};
          --color-orange-dark-1: ${base09};
          --color-yellow-dark-1: ${base0A};
          --color-olive-dark-1: ${base0B};
          --color-green-dark-1: ${base0B};
          --color-teal-dark-1: ${base0C};
          --color-violet-dark-1: ${base0E};
          --color-purple-dark-1: ${base0E};
          --color-pink-dark-1: ${base0F};
          --color-brown-dark-1: ${base09};
          --color-black-dark-1: ${base00};
          /* dark 2 variants */
          --color-red-dark-2: ${base08};
          --color-orange-dark-2: ${base09};
          --color-yellow-dark-2: ${base0A};
          --color-olive-dark-2: ${base0B};
          --color-green-dark-2: ${base0B};
          --color-teal-dark-2: ${base0C};
          --color-violet-dark-2: ${base0E};
          --color-purple-dark-2: ${base0E};
          --color-pink-dark-2: ${base0F};
          --color-brown-dark-2: ${base09};
          --color-black-dark-2: ${base00};
          /* ansi colors used for actions console and console files */
          --color-ansi-black: ${base00};
          --color-ansi-red: ${base08};
          --color-ansi-green: ${base0B};
          --color-ansi-yellow: ${base0A};
          --color-ansi-blue: ${base0D};
          --color-ansi-magenta: ${base0E};
          --color-ansi-cyan: ${base0C};
          --color-ansi-white: ${base04};
          --color-ansi-bright-black: ${base03};
          --color-ansi-bright-red: ${base08};
          --color-ansi-bright-green: ${base0B};
          --color-ansi-bright-yellow: ${base0A};
          --color-ansi-bright-blue: ${base0D};
          --color-ansi-bright-magenta: ${base0E};
          --color-ansi-bright-cyan: ${base0C};
          --color-ansi-bright-white: ${base05};
          /* other colors */
          --color-gold: ${base0A};
          --color-white: #ffffff;
          --color-pure-black: #000000;
          --color-diff-removed-word-bg: ${base08}66;
          --color-diff-added-word-bg: ${base0B}66;
          --color-diff-removed-row-bg: ${base08}22;
          --color-diff-moved-row-bg: ${base0A}22;
          --color-diff-added-row-bg: ${base0B}22;
          --color-diff-removed-row-border: ${base08};
          --color-diff-moved-row-border: ${base0A};
          --color-diff-added-row-border: ${base0B};
          --color-diff-inactive: ${base02};
          --color-error-border: ${base08};
          --color-error-bg: ${base08}22;
          --color-error-bg-active: ${base08}44;
          --color-error-bg-hover: ${base08}33;
          --color-error-text: ${base08};
          --color-success-border: ${base0B};
          --color-success-bg: ${base0B}22;
          --color-success-text: ${base0B};
          --color-warning-border: ${base0A};
          --color-warning-bg: ${base0A}22;
          --color-warning-text: ${base0A};
          --color-info-border: ${base0D};
          --color-info-bg: ${base0D}22;
          --color-info-text: ${base0D};
          --color-red-badge: ${base08};
          --color-red-badge-bg: ${base08}22;
          --color-red-badge-hover-bg: ${base08}44;
          --color-green-badge: ${base0B};
          --color-green-badge-bg: ${base0B}22;
          --color-green-badge-hover-bg: ${base0B}44;
          --color-yellow-badge: ${base0A};
          --color-yellow-badge-bg: ${base0A}22;
          --color-yellow-badge-hover-bg: ${base0A}44;
          --color-orange-badge: ${base09};
          --color-orange-badge-bg: ${base09}22;
          --color-orange-badge-hover-bg: ${base09}44;

          /* A more declarative way for themes */
          ${
          if isDark
          then ''
            --thin-lightness: 0.68;
            --regular-chroma: 0.19;
          ''
          else ''
            --thin-lightness: 0.53;
            --regular-chroma: 0.17;
          ''
        }
          --hue-green: 145deg;
          --hue-red: 27deg;
          --hue-purple: 298deg;
          --hue-violet: 293deg;
          --hue-orange: 41deg;
          --hue-blue: 260deg;

          --thin-lightness-highlight: 0.75;
          --color-thin-red-highlight: oklch(var(--thin-lightness-highlight) var(--regular-chroma) 27deg);

          --bg-lightness: 0.26;
          --bg-chroma: 0.05;
          --color-danger-bg: oklch(var(--bg-lightness) var(--bg-chroma) 27deg);

          /* target-based colors */
          --color-body: ${base00};
          --color-box-header: ${base01};
          --color-box-body: ${base01};
          --color-box-body-highlight: ${base02};
          --color-text-dark: ${base07};
          --color-text: ${base05};
          --color-text-light: ${
          if isDark
          then base05
          else base04
        };
          --color-text-light-1: ${
          if isDark
          then base05
          else base04
        };
          --color-text-light-2: ${
          if isDark
          then base05
          else base04
        };
          --color-text-light-3: ${base04};
          --color-footer: ${
          if isDark
          then base00
          else base01
        };
          --color-timeline: ${base02};
          --color-input-text: ${base05};
          --color-input-background: ${base02};
          --color-input-toggle-background: ${base02};
          --color-input-border: ${base03};
          --color-input-border-hover: ${base04};
          --color-header-wrapper: ${
          if isDark
          then base00
          else base01
        };
          --color-header-wrapper-transparent: ${base00}00;
          --color-light: ${
          if isDark
          then "#00000028"
          else "#ffffffcc"
        };
          --color-light-mimic-enabled: ${
          if isDark
          then "rgba(0, 0, 0, calc(40 / 255 * 222 / 255 / var(--opacity-disabled)))"
          else "rgba(0, 0, 0, calc(6 / 255 * 222 / 255 / var(--opacity-disabled)))"
        };
          --color-light-border: ${
          if isDark
          then "#ffffff28"
          else "#0000001d"
        };
          --color-hover: ${base02};
          --color-active: ${base03};
          --color-menu: ${base01};
          --color-card: ${base01};
          --fancy-card-bg: ${base01};
          --fancy-card-border: ${base02};
          --color-markup-table-row: ${base05}10;
          --color-markup-code-block: ${base02};
          --color-markup-code-inline: ${base02};
          --color-button: ${base03};
          --color-code-bg: ${base01};
          --color-shadow: #00000060;
          --color-secondary-bg: ${base01};
          --color-text-focus: ${base07};
          --color-expand-button: ${base02};
          --color-placeholder-text: ${base04};
          --color-editor-line-highlight: ${base02};
          --color-project-board-bg: var(--color-secondary-light-3);
          --color-project-board-dark-label: var(--color-text-light-3);
          --color-caret: var(--color-text);
          --color-reaction-bg: ${base05}1f;
          --color-reaction-active-bg: var(--color-primary-alpha-30);
          --color-reaction-hover-bg: var(--color-primary-alpha-40);
          --color-tooltip-text: ${base05};
          --color-tooltip-bg: ${base00}f0;
          --color-nav-bg: ${
          if isDark
          then base00
          else base01
        };
          --color-nav-hover-bg: ${base02};
          --color-secondary-nav-bg: var(--color-body);
          --color-label-text: ${base05};
          --color-label-bg: ${base02};
          --color-label-hover-bg: ${base03};
          --color-label-active-bg: ${base04};
          --color-label-bg-alt: ${base03};
          --color-accent: var(--color-primary-light-1);
          --color-small-accent: var(--color-primary-light-5);
          --color-highlight-fg: var(--color-primary-light-4);
          --color-highlight-bg: var(--color-primary-alpha-20);
          --color-overlay-backdrop: #080808c0;
          --color-selection-bg: ${base0D};
          --color-selection-fg: ${
          if isDark
          then base00
          else base07
        };
          /* pattern colors for image diff */
          --checkerboard-color-1: ${base02};
          --checkerboard-color-2: ${base01};
          --color-indicator-offline: ${base03};
          --color-indicator-offline-20: ${base03}1a;
          --color-indicator-idle: ${base0B};
          --color-indicator-idle-20: ${base0B}1a;
          --color-indicator-active: ${base0D};
          --color-indicator-active-20: ${base0D}33;
          accent-color: var(--color-accent);
          color-scheme: ${variant};
        }
        ${
          if isDark
          then ''
            /* invert emojis that are hard to read otherwise */
            .emoji[aria-label="check mark"],
            .emoji[aria-label="currency exchange"],
            .emoji[aria-label="TOP arrow"],
            .emoji[aria-label="END arrow"],
            .emoji[aria-label="ON! arrow"],
            .emoji[aria-label="SOON arrow"],
            .emoji[aria-label="heavy dollar sign"],
            .emoji[aria-label="copyright"],
            .emoji[aria-label="registered"],
            .emoji[aria-label="trade mark"],
            .emoji[aria-label="multiply"],
            .emoji[aria-label="plus"],
            .emoji[aria-label="minus"],
            .emoji[aria-label="divide"],
            .emoji[aria-label="curly loop"],
            .emoji[aria-label="double curly loop"],
            .emoji[aria-label="wavy dash"],
            .emoji[aria-label="paw prints"],
            .emoji[aria-label="musical note"],
            .emoji[aria-label="musical notes"] {
              filter: invert(100%) hue-rotate(180deg);
            }
          ''
          else ""
        }
        i.grey.icon.icon.icon.icon {
          color: ${base05} !important;
        }
        .ui.secondary.vertical.menu {
          border-radius: 0.28571429rem !important;
          overflow: hidden;
        }
        .ui.basic.primary.button.item {
          background-color: var(--color-active) !important;
          color: var(--color-text) !important;
          box-shadow: none !important;
        }
        .ui.red.label.notification_count,
        .ui.primary.label,
        .ui.primary.labels .label {
          background-color: ${
          if isDark
          then "var(--color-primary-light-3)"
          else "var(--color-primary-dark-1)"
        } !important;
        }
        .ui.labeled.icon.buttons > .button > .icon,
        .ui.labeled.icon.button > .icon {
          background-color: var(--color-light) !important;
        }
        #review-box .review-comments-counter {
          background-color: var(--color-shadow) !important;
          color: var(--color-white) !important;
          margin-inline-start: 0.5em;
        }
        .ui.basic.labels .primary.label,
        .ui.ui.ui.basic.primary.label {
          color: var(--color-text-dark) !important;
        }
        .ui.yellow.label.pending-label {
          color: var(--color-warning-text) !important;
        }
        .ui.basic.red.button {
          background-color: var(--color-red);
          color: var(--color-white);
        }
        .ui.basic.red.button:hover,
        .ui.basic.red.button:focus {
          background-color: var(--color-red-dark-1);
          color: var(--color-white);
        }
        .ui.basic.red.button:active {
          background-color: var(--color-red-dark-2);
          color: var(--color-white);
        }

        /* Chroma syntax highlighting - base16 palette */
        .chroma .bp { color: ${base09}; font-style: italic; }
        .chroma .c { color: ${base04}; font-style: italic; }
        .chroma .c1 { color: ${base04}; font-style: italic; }
        .chroma .ch { color: ${base04}; font-style: italic; }
        .chroma .cm { color: ${base04}; font-style: italic; }
        .chroma .cp { color: ${base0E}; }
        .chroma .cpf { color: ${base0B}; }
        .chroma .cs { color: ${base04}; font-style: italic; }
        .chroma .dl { color: ${base0B}; }
        .chroma .gd { color: ${base08}; background-color: ${base08}22; }
        .chroma .ge { color: ${base05}; font-style: italic; }
        .chroma .gh { color: ${base0E}; font-weight: bold; }
        .chroma .gi { color: ${base0B}; background-color: ${base0B}22; }
        .chroma .gl { text-decoration: underline; }
        .chroma .go { color: ${base03}; }
        .chroma .gp { color: ${base05}; }
        .chroma .gr { color: ${base08}; }
        .chroma .gs { color: ${base05}; font-weight: bold; }
        .chroma .gt { color: ${base08}; }
        .chroma .gu { color: ${base03}; }
        .chroma .il { color: ${base09}; }
        .chroma .k { color: ${base0E}; }
        .chroma .kc { color: ${base0E}; }
        .chroma .kd { color: ${base0E}; }
        .chroma .kn { color: ${base0E}; }
        .chroma .kp { color: ${base0E}; }
        .chroma .kr { color: ${base0E}; }
        .chroma .kt { color: ${base0A}; }
        .chroma .m { color: ${base09}; }
        .chroma .mb { color: ${base09}; }
        .chroma .mf { color: ${base09}; }
        .chroma .mh { color: ${base09}; }
        .chroma .mi { color: ${base09}; }
        .chroma .mo { color: ${base09}; }
        .chroma .n { color: ${base05}; }
        .chroma .na { color: ${base0D}; }
        .chroma .nb { color: ${base09}; }
        .chroma .nc { color: ${base0A}; }
        .chroma .nd { color: ${base0D}; }
        .chroma .ne { color: ${base0A}; }
        .chroma .nf { color: ${base0D}; }
        .chroma .ni { color: ${base05}; }
        .chroma .nl { color: ${base0E}; }
        .chroma .nn { color: ${base05}; }
        .chroma .no { color: ${base09}; }
        .chroma .nt { color: ${base08}; }
        .chroma .nv { color: ${base05}; }
        .chroma .nx { color: ${base05}; }
        .chroma .o { color: ${base05}; }
        .chroma .ow { color: ${base05}; }
        .chroma .p { color: ${base05}; }
        .chroma .s { color: ${base0B}; }
        .chroma .s1 { color: ${base0B}; }
        .chroma .s2 { color: ${base0B}; }
        .chroma .sa { color: ${base09}; }
        .chroma .sb { color: ${base0B}; }
        .chroma .sc { color: ${base0B}; }
        .chroma .sd { color: ${base0B}; }
        .chroma .se { color: ${base09}; }
        .chroma .sh { color: ${base0B}; }
        .chroma .si { color: ${base0B}; }
        .chroma .sr { color: ${base0C}; }
        .chroma .ss { color: ${base09}; }
        .chroma .sx { color: ${base0B}; }
        .chroma .vc { color: ${base05}; }
        .chroma .vg { color: ${base05}; }
        .chroma .vi { color: ${base05}; }
        .chroma .w { color: ${base03}; }
        .chroma .err { color: ${base08}; }
        .chroma .ln, .chroma .lnt { color: ${base04}; }
        .chroma .hl { background-color: ${base02}; }

        /* CodeMirror - markdown editor, base16 palette */
        .CodeMirror.cm-s-default .cm-property, .CodeMirror.cm-s-paper .cm-property { color: ${base0A}; }
        .CodeMirror.cm-s-default .cm-header, .CodeMirror.cm-s-paper .cm-header { color: ${base0E}; }
        .CodeMirror.cm-s-default .cm-quote, .CodeMirror.cm-s-paper .cm-quote { color: ${base0B}; }
        .CodeMirror.cm-s-default .cm-keyword, .CodeMirror.cm-s-paper .cm-keyword { color: ${base0E}; }
        .CodeMirror.cm-s-default .cm-atom, .CodeMirror.cm-s-paper .cm-atom { color: ${base09}; }
        .CodeMirror.cm-s-default .cm-number, .CodeMirror.cm-s-paper .cm-number { color: ${base09}; }
        .CodeMirror.cm-s-default .cm-def, .CodeMirror.cm-s-paper .cm-def { color: ${base05}; }
        .CodeMirror.cm-s-default .cm-variable-2, .CodeMirror.cm-s-paper .cm-variable-2 { color: ${base0C}; }
        .CodeMirror.cm-s-default .cm-variable-3, .CodeMirror.cm-s-paper .cm-variable-3 { color: ${base0D}; }
        .CodeMirror.cm-s-default .cm-comment, .CodeMirror.cm-s-paper .cm-comment { color: ${base04}; font-style: italic; }
        .CodeMirror.cm-s-default .cm-string, .CodeMirror.cm-s-paper .cm-string { color: ${base0B}; }
        .CodeMirror.cm-s-default .cm-string-2, .CodeMirror.cm-s-paper .cm-string-2 { color: ${base09}; }
        .CodeMirror.cm-s-default .cm-meta, .CodeMirror.cm-s-paper .cm-meta,
        .CodeMirror.cm-s-default .cm-qualifier, .CodeMirror.cm-s-paper .cm-qualifier { color: ${base0E}; }
        .CodeMirror.cm-s-default .cm-builtin, .CodeMirror.cm-s-paper .cm-builtin { color: ${base09}; }
        .CodeMirror.cm-s-default .cm-bracket, .CodeMirror.cm-s-paper .cm-bracket { color: ${base05}; }
        .CodeMirror.cm-s-default .cm-tag, .CodeMirror.cm-s-paper .cm-tag { color: ${base08}; }
        .CodeMirror.cm-s-default .cm-attribute, .CodeMirror.cm-s-paper .cm-attribute { color: ${base0D}; }
        .CodeMirror.cm-s-default .cm-hr, .CodeMirror.cm-s-paper .cm-hr { color: ${base03}; }
        .CodeMirror.cm-s-default .cm-url, .CodeMirror.cm-s-paper .cm-url { color: ${base0C}; }
        .CodeMirror.cm-s-default .cm-link, .CodeMirror.cm-s-paper .cm-link { color: ${base0E}; }
        .CodeMirror.cm-s-default .cm-error, .CodeMirror.cm-s-paper .cm-error { color: ${base08}; }
      '';
    themeName = attrs.name;
    darkFile = pkgs.writeText "theme-${themeName}-dark.css" (mkThemeCss "dark");
    lightFile = pkgs.writeText "theme-${themeName}-light.css" (mkThemeCss "light");
    autoFile = pkgs.writeText "theme-${themeName}-auto.css" ''
      @import "theme-${themeName}-light.css";
      @import "theme-${themeName}-dark.css" (prefers-color-scheme: dark);
    '';
  in {
    services.forgejo.settings.ui = {
      THEMES = "forgejo-auto,${themeName}-auto,${themeName}-dark,${themeName}-light";
      DEFAULT_THEME = "${themeName}-auto";
    };
    system.activationScripts.forgejo-theme = let
      inherit (cfg) user group;
      publicDir = "${cfg.customDir}/public";
      assetsDir = "${publicDir}/assets";
      darkLink = "${cssDir}/theme-${themeName}-dark.css";
      lightLink = "${cssDir}/theme-${themeName}-light.css";
      autoLink = "${cssDir}/theme-${themeName}-auto.css";
    in {
      text = ''
        install -dm750 -o ${lib.escapeShellArg user} -g ${lib.escapeShellArg group} ${lib.escapeShellArg publicDir} ${lib.escapeShellArg assetsDir} ${lib.escapeShellArg cssDir}
        ln -sfn ${darkFile} ${lib.escapeShellArg darkLink}
        ln -sfn ${lightFile} ${lib.escapeShellArg lightLink}
        ln -sfn ${autoFile} ${lib.escapeShellArg autoLink}
        chown -h ${lib.escapeShellArg "${user}:${group}"} ${lib.escapeShellArg darkLink} ${lib.escapeShellArg lightLink} ${lib.escapeShellArg autoLink}
      '';
    };
  };
}
