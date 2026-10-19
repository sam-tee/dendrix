{self, ...}: {
  flake.modules = {
    nixos.mangowc = {pkgs, ...}: {
      imports = [self.modules.nixos.wm];
      hjem.extraModules = [self.modules.hjem.mangowc];
      programs.mango = {
        enable = true;
        package = pkgs.mango;
      };
    };
    hjem.mangowc = _: let
      dirBind = mod: name: left: right: up: down: ''
        bind=${mod},${left},${name},left
        bind=${mod},${right},${name},right
        bind=${mod},${up},${name},up
        bind=${mod},${down},${name},down'';
      tagBinds =
        9
        |> builtins.genList (i: let
          n = toString (i + 1);
        in "bind=SUPER,${n},view,${n}\nbind=SUPER+SHIFT,${n},tag,${n}")
        |> builtins.concatStringsSep "\n";
      tagRules =
        9
        |> builtins.genList (i: "tag_rule=id:${toString (i + 1)},no_hide:1")
        |> builtins.concatStringsSep "\n";
    in {
      xdg.config.files."mango/config.conf".text = ''
        xkb_rules_layout=gb
        xkb_rules_options=caps:escape
        trackpad_natural_scrolling=1

        border_px=1
        border_px=0
        gap_inner_horizontal=0
        gap_inner_vertical=0
        gap_outer_horizontal=0
        gap_outer_vertical=0
        animations=0
        layer_animations=0

        sloppy_focus=1
        idle_inhibit_when_fullscreen=1
        circle_layout=dwindle,scroller,monocle

        bind=SUPER,Return,spawn,ghostty
        bind=SUPER,B,spawn,helium --new-window --ozone-platform=wayland
        bind=SUPER,E,spawn,ghostty -e yazi
        bind=SUPER,Z,spawn,zeditor

        bind=SUPER,space,spawn,noctalia msg panel-toggle launcher
        bind=SUPER,S,spawn,noctalia msg panel-toggle control-center
        bind=SUPER,comma,spawn,noctalia msg settings toggle
        bind=SUPER+SHIFT,comma,spawn,noctalia msg settings toggle
        bind=SUPER+SHIFT,S,spawn,noctalia msg screenshot-region
        bind=SUPER+SHIFT,V,spawn,noctalia msg panel-toggle clipboard

        bind=SUPER,Q,killclient
        bind=SUPER,V,togglefloating
        bind=SUPER,F,togglefullscreen
        bind=SUPER,M,centerwin
        bind=SUPER,R,setkeymode,resize
        bind=SUPER,C,switch_layout

        ${dirBind "SUPER" "focusdir" "H" "L" "K" "J"}
        ${dirBind "SUPER" "focusdir" "Left" "Right" "Up" "Down"}

        ${dirBind "SUPER+SHIFT" "move_client" "H" "L" "K" "J"}
        ${dirBind "SUPER+SHIFT" "move_client" "Left" "Right" "Up" "Down"}

        bind=SUPER+SHIFT+ALT,Left,exchange_client,left
        bind=SUPER+SHIFT+ALT,Right,exchange_client,right
        bind=SUPER+SHIFT+ALT,Up,exchange_client,up
        bind=SUPER+SHIFT+ALT,Down,exchange_client,down

        bind=SUPER,minus,resizewin,-100,0
        bind=SUPER,equal,resizewin,+100,0
        bind=SUPER+SHIFT,minus,resizewin,0,-100
        bind=SUPER+SHIFT,equal,resizewin,0,+100

        ${tagBinds}
        ${tagRules}

        bind=SUPER+SHIFT,Escape,quit
        bind=SUPER+SHIFT,R,reload_config

        bind=NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up
        bind=NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down
        bind=NONE,XF86AudioMute,spawn,noctalia msg volume-mute
        bind=NONE,XF86AudioMicMute,spawn,noctalia msg mic-mute
        bind=NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up
        bind=NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down

        mousebind=SUPER,btn_left,moveresize,curmove
        mousebind=SUPER,btn_right,moveresize,curresize
        mousebind=SUPER+ALT,btn_left,moveresize,curresize

        window_rule=is_floating:1,title:Picture.*(in)?.*[Pp]icture
        window_rule=is_floating:1,is_fullscreen:1,app_id:gamescope

        key_mode=resize
        bind=NONE,H,resizewin,-100,0
        bind=NONE,L,resizewin,+100,0
        bind=NONE,K,resizewin,0,-100
        bind=NONE,J,resizewin,0,+100
        bind=NONE,Left,resizewin,-100,0
        bind=NONE,Right,resizewin,+100,0
        bind=NONE,Up,resizewin,0,-100
        bind=NONE,Down,resizewin,0,+100
        bind=NONE,Escape,setkeymode,default
        key_mode=default
      '';
    };
  };
}
