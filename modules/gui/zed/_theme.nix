theme: {
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  author = theme.author;
  name = theme.name;
  themes = [
    {
      appearance = theme.variant;
      name = theme.name;
      style = {
        background = "${theme.base00}";
        "background.appearance" = "transparent";
        border = "${theme.base04}30";
        "border.disabled" = "${theme.base04}";
        "border.focused" = "${theme.base05}";
        "border.selected" = "${theme.base0E}";
        "border.transparent" = "${theme.base0B}";
        "border.variant" = "${theme.base04}00";
        conflict = "${theme.base0A}";
        "conflict.background" = "${theme.base01}";
        "conflict.border" = "${theme.base0A}";
        created = "${theme.base0B}";
        "created.background" = "${theme.base01}";
        "created.border" = "${theme.base0B}";
        deleted = "${theme.base08}";
        "deleted.background" = "${theme.base01}";
        "deleted.border" = "${theme.base08}";
        "drop_target.background" = "${theme.base00}66";
        "editor.active_line.background" = "${theme.base05}10";
        "editor.active_line_number" = "${theme.base0E}";
        "editor.active_wrap_guide" = "${theme.base04}";
        "editor.background" = "${theme.base00}00";
        "editor.document_highlight.bracket_background" = "${theme.base04}59";
        "editor.document_highlight.read_background" = "${theme.base05}29";
        "editor.document_highlight.write_background" = "${theme.base05}29";
        "editor.foreground" = "${theme.base05}";
        "editor.gutter.background" = "${theme.base00}00";
        "editor.highlighted_line.background" = null;
        "editor.indent_guide" = "${theme.base02}";
        "editor.indent_guide_active" = "${theme.base04}";
        "editor.invisible" = "${theme.base05}";
        "editor.line_number" = "${theme.base04}";
        "editor.subheader.background" = "${theme.base00}00";
        "editor.wrap_guide" = "${theme.base04}";
        "element.active" = "${theme.base04}4d";
        "element.background" = "${theme.base00}";
        "element.disabled" = "${theme.base0A}";
        "element.hover" = "${theme.base04}4d";
        "element.selected" = "${theme.base04}33";
        "elevated_surface.background" = "${theme.base00}";
        error = "${theme.base08}";
        "error.background" = "${theme.base08}1f";
        "error.border" = "${theme.base08}";
        "ghost_element.active" = "${theme.base04}99";
        "ghost_element.background" = "${theme.base00}59";
        "ghost_element.disabled" = "${theme.base0A}";
        "ghost_element.hover" = "${theme.base04}4d";
        "ghost_element.selected" = "${theme.base05}1a";
        hidden = "${theme.base04}";
        "hidden.background" = "${theme.base01}";
        "hidden.border" = "${theme.base04}";
        hint = "${theme.base04}";
        "hint.background" = "${theme.base01}";
        "hint.border" = "${theme.base04}";
        icon = "${theme.base0E}";
        "icon.accent" = "${theme.base0E}";
        "icon.disabled" = "${theme.base04}";
        "icon.muted" = "${theme.base0E}50";
        "icon.placeholder" = "${theme.base04}";
        ignored = "${theme.base04}";
        "ignored.background" = "${theme.base01}";
        "ignored.border" = "${theme.base04}";
        info = "${theme.base0C}";
        "info.background" = "${theme.base05}33";
        "info.border" = "${theme.base0C}";
        "link_text.hover" = "${theme.base0D}";
        modified = "${theme.base0A}";
        "modified.background" = "${theme.base01}";
        "modified.border" = "${theme.base0A}";
        "pane.focused_border" = "${theme.base05}";
        "pane_group.border" = "${theme.base00}";
        "panel.background" = "${theme.base00}00";
        "panel.focused_border" = "${theme.base04}";
        "panel.indent_guide" = "${theme.base04}99";
        "panel.indent_guide_active" = "${theme.base04}";
        "panel.indent_guide_hover" = "${theme.base0E}";
        players = [
          {
            background = "${theme.base05}";
            cursor = "${theme.base05}";
            selection = "${theme.base05}33";
          }
          {
            background = "${theme.base0E}";
            cursor = "${theme.base0E}";
            selection = "${theme.base0E}33";
          }
          {
            background = "${theme.base07}";
            cursor = "${theme.base07}";
            selection = "${theme.base07}33";
          }
          {
            background = "${theme.base0D}";
            cursor = "${theme.base0D}";
            selection = "${theme.base0D}33";
          }
          {
            background = "${theme.base0B}";
            cursor = "${theme.base0B}";
            selection = "${theme.base0B}33";
          }
          {
            background = "${theme.base0A}";
            cursor = "${theme.base0A}";
            selection = "${theme.base0A}33";
          }
          {
            background = "${theme.base09}";
            cursor = "${theme.base09}";
            selection = "${theme.base09}33";
          }
          {
            background = "$COLOURF_";
            cursor = "$COLOURF_";
            selection = "$COLOURF_33";
          }
        ];
        predictive = "${theme.base04}";
        "predictive.background" = "${theme.base01}";
        "predictive.border" = "${theme.base07}";
        renamed = "${theme.base0D}";
        "renamed.background" = "${theme.base01}";
        "renamed.border" = "${theme.base0D}";
        "scrollbar.thumb.background" = "${theme.base0E}33";
        "scrollbar.thumb.border" = "${theme.base0E}";
        "scrollbar.thumb.hover_background" = "${theme.base04}";
        "scrollbar.track.background" = null;
        "scrollbar.track.border" = "${theme.base05}12";
        "search.match_background" = "${theme.base0C}33";
        "status_bar.background" = "${theme.base00}";
        success = "${theme.base0B}";
        "success.background" = "${theme.base0B}1f";
        "success.border" = "${theme.base0B}";
        "surface.background" = "${theme.base00}";
        syntax = {
          attribute = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          boolean = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          character = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          "character.special" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          comment = {
            color = "${theme.base04}";
            font_style = null;
            font_weight = null;
          };
          "comment.doc" = {
            color = "${theme.base04}";
            font_style = null;
            font_weight = null;
          };
          "comment.documentation" = {
            color = "${theme.base04}";
            font_style = null;
            font_weight = null;
          };
          "comment.error" = {
            color = "${theme.base08}";
            font_style = null;
            font_weight = null;
          };
          "comment.hint" = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          "comment.note" = {
            color = "${theme.base06}";
            font_style = null;
            font_weight = null;
          };
          "comment.todo" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "comment.warning" = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          concept = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          constant = {
            color = "${theme.base06}";
            font_style = null;
            font_weight = null;
          };
          "constant.builtin" = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          "constant.macro" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          constructor = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "diff.minus" = {
            color = "${theme.base08}";
            font_style = null;
            font_weight = null;
          };
          "diff.plus" = {
            color = "${theme.base0B}";
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
            color = "${theme.base0C}";
            font_style = null;
            font_weight = 700;
          };
          field = {
            color = "${theme.base07}";
            font_style = null;
            font_weight = null;
          };
          float = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          function = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          "function.builtin" = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          "function.call" = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          "function.decorator" = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          "function.macro" = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          "function.method" = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          "function.method.call" = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          hint = {
            color = "${theme.base04}";
            font_style = null;
            font_weight = null;
          };
          keyword = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.conditional" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.conditional.ternary" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.coroutine" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.debug" = {
            color = "${theme.base0E}";
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
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.export" = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          "keyword.function" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.import" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.modifier" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.operator" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.repeat" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.return" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "keyword.type" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          label = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          link_text = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          link_uri = {
            color = "${theme.base06}";
            font_style = null;
            font_weight = null;
          };
          module = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          namespace = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          number = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          "number.float" = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          operator = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          parameter = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          parent = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          predictive = {
            color = "${theme.base04}";
            font_style = null;
            font_weight = null;
          };
          predoc = {
            color = "${theme.base08}";
            font_style = null;
            font_weight = null;
          };
          primary = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          property = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          punctuation = {
            color = "${theme.base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.bracket" = {
            color = "${theme.base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.delimiter" = {
            color = "${theme.base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.list_marker" = {
            color = "${theme.base0C}";
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
            color = "${theme.base0B}";
            font_style = null;
            font_weight = null;
          };
          "string.doc" = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.documentation" = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.escape" = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          "string.regex" = {
            color = "${theme.base09}";
            font_style = null;
            font_weight = null;
          };
          "string.regexp" = {
            color = "${theme.base09}";
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
            color = "${theme.base06}";
            font_style = null;
            font_weight = null;
          };
          symbol = {
            color = "$COLOURF_";
            font_style = null;
            font_weight = null;
          };
          tag = {
            color = "${theme.base0D}";
            font_style = null;
            font_weight = null;
          };
          "tag.attribute" = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          "tag.delimiter" = {
            color = "${theme.base0C}";
            font_style = null;
            font_weight = null;
          };
          "tag.doctype" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          text = {
            color = "${theme.base05}";
            font_style = null;
            font_weight = null;
          };
          "text.literal" = {
            color = "${theme.base0B}";
            font_style = null;
            font_weight = null;
          };
          title = {
            color = "${theme.base05}";
            font_style = null;
            font_weight = 800;
          };
          type = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          "type.builtin" = {
            color = "${theme.base0E}";
            font_style = null;
            font_weight = null;
          };
          "type.class.definition" = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = 700;
          };
          "type.definition" = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          "type.interface" = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          "type.super" = {
            color = "${theme.base0A}";
            font_style = null;
            font_weight = null;
          };
          variable = {
            color = "${theme.base05}";
            font_style = null;
            font_weight = null;
          };
          "variable.builtin" = {
            color = "${theme.base08}";
            font_style = null;
            font_weight = null;
          };
          "variable.member" = {
            color = "${theme.base0D}";
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
            color = "${theme.base08}";
            font_style = null;
            font_weight = null;
          };
        };
        "tab.active_background" = "${theme.base00}";
        "tab.inactive_background" = "${theme.base00}";
        "tab_bar.background" = "${theme.base00}";
        "terminal.ansi.background" = "${theme.base00}00";
        "terminal.ansi.black" = "${theme.base04}";
        "terminal.ansi.blue" = "${theme.base0D}";
        "terminal.ansi.bright_black" = "${theme.base04}";
        "terminal.ansi.bright_blue" = "${theme.base0D}";
        "terminal.ansi.bright_cyan" = "${theme.base0C}";
        "terminal.ansi.bright_green" = "${theme.base0B}";
        "terminal.ansi.bright_magenta" = "${theme.base0E}";
        "terminal.ansi.bright_red" = "${theme.base08}";
        "terminal.ansi.bright_white" = "${theme.base05}";
        "terminal.ansi.bright_yellow" = "${theme.base0A}";
        "terminal.ansi.cyan" = "${theme.base0C}";
        "terminal.ansi.dim_black" = "${theme.base04}";
        "terminal.ansi.dim_blue" = "${theme.base0D}";
        "terminal.ansi.dim_cyan" = "${theme.base0C}";
        "terminal.ansi.dim_green" = "${theme.base0B}";
        "terminal.ansi.dim_magenta" = "${theme.base0E}";
        "terminal.ansi.dim_red" = "${theme.base08}";
        "terminal.ansi.dim_white" = "${theme.base05}";
        "terminal.ansi.dim_yellow" = "${theme.base0A}";
        "terminal.ansi.green" = "${theme.base0B}";
        "terminal.ansi.magenta" = "${theme.base0E}";
        "terminal.ansi.red" = "${theme.base08}";
        "terminal.ansi.white" = "${theme.base05}";
        "terminal.ansi.yellow" = "${theme.base0A}";
        "terminal.background" = "${theme.base00}00";
        "terminal.bright_foreground" = "${theme.base05}";
        "terminal.dim_foreground" = "${theme.base04}";
        "terminal.foreground" = "${theme.base05}";
        text = "${theme.base05}";
        "text.accent" = "${theme.base0E}";
        "text.disabled" = "${theme.base03}";
        "text.muted" = "${theme.base04}";
        "text.placeholder" = "${theme.base04}";
        "title_bar.background" = "${theme.base00}";
        "title_bar.inactive_background" = "${theme.base01}";
        "toolbar.background" = "${theme.base00}00";
        unreachable = "${theme.base08}";
        "unreachable.background" = "${theme.base08}1f";
        "unreachable.border" = "${theme.base08}";
        warning = "${theme.base0A}";
        "warning.background" = "${theme.base0A}1f";
        "warning.border" = "${theme.base0A}";
      };
    }
  ];
}
