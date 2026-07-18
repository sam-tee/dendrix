theme: variant: let
  name = "${theme.name}-${variant}";
  inherit (theme) author;
in {
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  inherit author name;
  themes = with theme.${variant}; [
    {
      appearance = variant;
      inherit name;
      style = {
        background = "${base00}";
        "background.appearance" = "transparent";
        border = "${base04}30";
        "border.disabled" = "${base04}";
        "border.focused" = "${base05}";
        "border.selected" = "${base0E}";
        "border.transparent" = "${base0B}";
        "border.variant" = "${base04}00";
        conflict = "${base0A}";
        "conflict.background" = "${base01}";
        "conflict.border" = "${base0A}";
        created = "${base0B}";
        "created.background" = "${base01}";
        "created.border" = "${base0B}";
        deleted = "${base08}";
        "deleted.background" = "${base01}";
        "deleted.border" = "${base08}";
        "drop_target.background" = "${base00}66";
        "editor.active_line.background" = "${base05}10";
        "editor.active_line_number" = "${base0E}";
        "editor.active_wrap_guide" = "${base04}";
        "editor.background" = "${base00}00";
        "editor.document_highlight.bracket_background" = "${base04}59";
        "editor.document_highlight.read_background" = "${base05}29";
        "editor.document_highlight.write_background" = "${base05}29";
        "editor.foreground" = "${base05}";
        "editor.gutter.background" = "${base00}00";
        "editor.highlighted_line.background" = null;
        "editor.indent_guide" = "${base02}";
        "editor.indent_guide_active" = "${base04}";
        "editor.invisible" = "${base05}";
        "editor.line_number" = "${base04}";
        "editor.subheader.background" = "${base00}00";
        "editor.wrap_guide" = "${base04}";
        "element.active" = "${base04}4d";
        "element.background" = "${base00}";
        "element.disabled" = "${base0A}";
        "element.hover" = "${base04}4d";
        "element.selected" = "${base04}33";
        "elevated_surface.background" = "${base00}";
        error = "${base08}";
        "error.background" = "${base08}1f";
        "error.border" = "${base08}";
        "ghost_element.active" = "${base04}99";
        "ghost_element.background" = "${base00}59";
        "ghost_element.disabled" = "${base0A}";
        "ghost_element.hover" = "${base04}4d";
        "ghost_element.selected" = "${base05}1a";
        hidden = "${base04}";
        "hidden.background" = "${base01}";
        "hidden.border" = "${base04}";
        hint = "${base04}";
        "hint.background" = "${base01}";
        "hint.border" = "${base04}";
        icon = "${base0E}";
        "icon.accent" = "${base0E}";
        "icon.disabled" = "${base04}";
        "icon.muted" = "${base0E}50";
        "icon.placeholder" = "${base04}";
        ignored = "${base04}";
        "ignored.background" = "${base01}";
        "ignored.border" = "${base04}";
        info = "${base0C}";
        "info.background" = "${base05}33";
        "info.border" = "${base0C}";
        "link_text.hover" = "${base0D}";
        modified = "${base0A}";
        "modified.background" = "${base01}";
        "modified.border" = "${base0A}";
        "pane.focused_border" = "${base05}";
        "pane_group.border" = "${base00}";
        "panel.background" = "${base00}00";
        "panel.focused_border" = "${base04}";
        "panel.indent_guide" = "${base04}99";
        "panel.indent_guide_active" = "${base04}";
        "panel.indent_guide_hover" = "${base0E}";
        players = [
          {
            background = "${base05}";
            cursor = "${base05}";
            selection = "${base05}33";
          }
          {
            background = "${base0E}";
            cursor = "${base0E}";
            selection = "${base0E}33";
          }
          {
            background = "${base07}";
            cursor = "${base07}";
            selection = "${base07}33";
          }
          {
            background = "${base0D}";
            cursor = "${base0D}";
            selection = "${base0D}33";
          }
          {
            background = "${base0B}";
            cursor = "${base0B}";
            selection = "${base0B}33";
          }
          {
            background = "${base0A}";
            cursor = "${base0A}";
            selection = "${base0A}33";
          }
          {
            background = "${base09}";
            cursor = "${base09}";
            selection = "${base09}33";
          }
          {
            background = "$COLOURF_";
            cursor = "$COLOURF_";
            selection = "$COLOURF_33";
          }
        ];
        predictive = "${base04}";
        "predictive.background" = "${base01}";
        "predictive.border" = "${base07}";
        renamed = "${base0D}";
        "renamed.background" = "${base01}";
        "renamed.border" = "${base0D}";
        "scrollbar.thumb.background" = "${base0E}33";
        "scrollbar.thumb.border" = "${base0E}";
        "scrollbar.thumb.hover_background" = "${base04}";
        "scrollbar.track.background" = null;
        "scrollbar.track.border" = "${base05}12";
        "search.match_background" = "${base0C}33";
        "status_bar.background" = "${base00}";
        success = "${base0B}";
        "success.background" = "${base0B}1f";
        "success.border" = "${base0B}";
        "surface.background" = "${base00}";
        syntax = {
          attribute = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          boolean = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          character = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "character.special" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          comment = {
            color = "${base04}";
            font_style = null;
            font_weight = null;
          };
          "comment.doc" = {
            color = "${base04}";
            font_style = null;
            font_weight = null;
          };
          "comment.documentation" = {
            color = "${base04}";
            font_style = null;
            font_weight = null;
          };
          "comment.error" = {
            color = "${base08}";
            font_style = null;
            font_weight = null;
          };
          "comment.hint" = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "comment.note" = {
            color = "${base06}";
            font_style = null;
            font_weight = null;
          };
          "comment.todo" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "comment.warning" = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          concept = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          constant = {
            color = "${base06}";
            font_style = null;
            font_weight = null;
          };
          "constant.builtin" = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          "constant.macro" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          constructor = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "diff.minus" = {
            color = "${base08}";
            font_style = null;
            font_weight = null;
          };
          "diff.plus" = {
            color = "${base0B}";
            font_style = null;
            font_weight = null;
          };
          embedded = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          emphasis = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "emphasis.strong" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = 700;
          };
          enum = {
            color = "${base0C}";
            font_style = null;
            font_weight = 700;
          };
          field = {
            color = "${base07}";
            font_style = null;
            font_weight = null;
          };
          float = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          function = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "function.builtin" = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          "function.call" = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "function.decorator" = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          "function.macro" = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "function.method" = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "function.method.call" = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          hint = {
            color = "${base04}";
            font_style = null;
            font_weight = null;
          };
          keyword = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.conditional" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.conditional.ternary" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.coroutine" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.debug" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.directive" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "keyword.directive.define" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "keyword.exception" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.export" = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "keyword.function" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.import" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.modifier" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.operator" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.repeat" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.return" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.type" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          label = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          link_text = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          link_uri = {
            color = "${base06}";
            font_style = null;
            font_weight = null;
          };
          module = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          namespace = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          number = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "number.float" = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          operator = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          parameter = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          parent = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          predictive = {
            color = "${base04}";
            font_style = null;
            font_weight = null;
          };
          predoc = {
            color = "${base08}";
            font_style = null;
            font_weight = null;
          };
          primary = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          property = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          punctuation = {
            color = "${base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.bracket" = {
            color = "${base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.delimiter" = {
            color = "${base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.list_marker" = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.special" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "punctuation.special.symbol" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          string = {
            color = "${base0B}";
            font_style = null;
            font_weight = null;
          };
          "string.doc" = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.documentation" = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.escape" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "string.regex" = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          "string.regexp" = {
            color = "${base09}";
            font_style = null;
            font_weight = null;
          };
          "string.special" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "string.special.path" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "string.special.symbol" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "string.special.url" = {
            color = "${base06}";
            font_style = null;
            font_weight = null;
          };
          symbol = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          tag = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "tag.attribute" = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          "tag.delimiter" = {
            color = "${base0C}";
            font_style = null;
            font_weight = null;
          };
          "tag.doctype" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          text = {
            color = "${base05}";
            font_style = null;
            font_weight = null;
          };
          "text.literal" = {
            color = "${base0B}";
            font_style = null;
            font_weight = null;
          };
          title = {
            color = "${base05}";
            font_style = null;
            font_weight = 800;
          };
          type = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          "type.builtin" = {
            color = "${base0E}";
            font_style = null;
            font_weight = null;
          };
          "type.class.definition" = {
            color = "${base0A}";
            font_style = null;
            font_weight = 700;
          };
          "type.definition" = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          "type.interface" = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          "type.super" = {
            color = "${base0A}";
            font_style = null;
            font_weight = null;
          };
          variable = {
            color = "${base05}";
            font_style = null;
            font_weight = null;
          };
          "variable.builtin" = {
            color = "${base08}";
            font_style = null;
            font_weight = null;
          };
          "variable.member" = {
            color = "${base0D}";
            font_style = null;
            font_weight = null;
          };
          "variable.parameter" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "variable.special" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          variant = {
            color = "${base08}";
            font_style = null;
            font_weight = null;
          };
        };
        "tab.active_background" = "${base00}";
        "tab.inactive_background" = "${base00}";
        "tab_bar.background" = "${base00}";
        "terminal.ansi.background" = "${base00}00";
        "terminal.ansi.black" = "${base04}";
        "terminal.ansi.blue" = "${base0D}";
        "terminal.ansi.bright_black" = "${base04}";
        "terminal.ansi.bright_blue" = "${base0D}";
        "terminal.ansi.bright_cyan" = "${base0C}";
        "terminal.ansi.bright_green" = "${base0B}";
        "terminal.ansi.bright_magenta" = "${base0E}";
        "terminal.ansi.bright_red" = "${base08}";
        "terminal.ansi.bright_white" = "${base05}";
        "terminal.ansi.bright_yellow" = "${base0A}";
        "terminal.ansi.cyan" = "${base0C}";
        "terminal.ansi.dim_black" = "${base04}";
        "terminal.ansi.dim_blue" = "${base0D}";
        "terminal.ansi.dim_cyan" = "${base0C}";
        "terminal.ansi.dim_green" = "${base0B}";
        "terminal.ansi.dim_magenta" = "${base0E}";
        "terminal.ansi.dim_red" = "${base08}";
        "terminal.ansi.dim_white" = "${base05}";
        "terminal.ansi.dim_yellow" = "${base0A}";
        "terminal.ansi.green" = "${base0B}";
        "terminal.ansi.magenta" = "${base0E}";
        "terminal.ansi.red" = "${base08}";
        "terminal.ansi.white" = "${base05}";
        "terminal.ansi.yellow" = "${base0A}";
        "terminal.background" = "${base00}00";
        "terminal.bright_foreground" = "${base05}";
        "terminal.dim_foreground" = "${base04}";
        "terminal.foreground" = "${base05}";
        text = "${base05}";
        "text.accent" = "${base0E}";
        "text.disabled" = "${base03}";
        "text.muted" = "${base04}";
        "text.placeholder" = "${base04}";
        "title_bar.background" = "${base00}";
        "title_bar.inactive_background" = "${base01}";
        "toolbar.background" = "${base00}00";
        unreachable = "${base08}";
        "unreachable.background" = "${base08}1f";
        "unreachable.border" = "${base08}";
        warning = "${base0A}";
        "warning.background" = "${base0A}1f";
        "warning.border" = "${base0A}";
      };
    }
  ];
}
