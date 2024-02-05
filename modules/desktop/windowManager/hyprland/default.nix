{ config, inputs, lib, pkgs, ...}:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;

  gameMode = pkgs.writeShellScriptBin "gamemode" ''
    HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==2{print $2}')
    if [ "$HYPRGAMEMODE" = 1 ] ; then
      hyprctl --batch "\
          keyword animations:enabled 0;\
          keyword decoration:drop_shadow 0;\
          keyword decoration:blur 0;\
          keyword general:gaps_in 0;\
          keyword general:gaps_out 0;\
          keyword general:border_size 1;\
          keyword decoration:rounding 0"
      exit
    else
      hyprctl --batch "\
          keyword animations:enabled 1;\
          keyword decoration:drop_shadow 1;\
          keyword decoration:blur 1;\
          keyword general:gaps_in 1;\
          keyword general:gaps_out 1;\
          keyword general:border_size 1;\
          keyword decoration:rounding 1"
    fi
    hyprctl reload
  '';
in
with lib;
{
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    home = {
      packages = with pkgs;
        [
          gameMode
          #hyprland-share-picker     # If this works outside of Hyprland modularize
        ];
    };

    host = {
      home = {
        applications = {
          hyprpicker.enable = true;
          playerctl.enable = true;
          rofi.enable = true;
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      extraConfig = ''
        #source=~/src/home/dotfiles/hypr/hyprland.conf

        # Hardware

        ## Display
        $monitor_left=DP-3
        $monitor_middle=DP-2
        $monitor_right=HDMI-A-1
        monitor=$monitor_left,2560x1440@119.998001,0x0,1.0
        monitor=$monitor_middle,2560x1440@119.998001,2560x0,1.0
        monitor=$monitor_right,2560x1440@60.0,5120x0,1.0

        ## Input
        input {
          follow_mouse = 1
          kb_layout = de
          kb_model =
          kb_options =
          kb_rules =
          kb_variant =
          numlock_by_default = true
          repeat_delay = 200
          repeat_rate = 40
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
          touchpad {
            natural_scroll = no
          }
        }

        gestures {
            workspace_swipe = off
        }


        # Environment Variables
        env = XCURSOR_SIZE,24
        env = XDG_SESSION_DESKTOP,Hyprland
        env = GDK_BACKEND,wayland,x11
        env = QT_QPA_PLATFORM,wayland;xcb
        env = SDL_VIDEODRIVER,wayland
        env = CLUTTER_BACKEND,wayland
        env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

        # Misc
        misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          force_hypr_chan = false
          #key_press_enables_dpms = true
          #vrr = 1
        }

        # Workspaces
        workspace=$monitor_left,1
        workspace=$monitor_left,4
        workspace=$monitor_left,7
        workspace=$monitor_middle,2
        workspace=$monitor_middle,5
        workspace=$monitor_middle,8
        workspace=$monitor_right,3
        workspace=$monitor_right,6
        workspace=$monitor_right,9
        wsbind 1,$monitor_left
        wsbind 4,$monitor_left
        wsbind 7,$monitor_left
        wsbind 2,$monitor_middle
        wsbind 5,$monitor_middle
        wsbind 8,$monitor_middle
        wsbind 3,$monitor_right
        wsbind 6,$monitor_right
        wsbind 9,$monitor_right

        # Startup Applications
        #exec-once = dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
        exec-once = "~/.config/scripts/decrypt.sh"
        #exec-once = ferdium --ozone-platform=wayland --enable-features-WaylandWindowDecorations
        exec-once = hyprpaper
        exec-once = nextcloud --background
        exec-once = opensnitch-ui --background
        exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec      = swayidle -w timeout 600 'echo "$(date) 600" >> /tmp/swayidle.log ; swaylock -C ~/.config/swaylock/swaylock.conf -S --effect-pixelate 7' timeout 1200 'echo "$(date) 1200" >> /tmp/swayidle.log ; hyprctl dispatch dpms off' resume 'echo "$(date) resume" >> /tmp/swayidle.log ; hyprctl dispatch dpms on' before-sleep 'echo "$(date) before-sleep" >> /tmp/swayidle.log ; swaylock -C ~/.config/swaylock/swaylock.conf'
        exec      = swayosd --display=HDMI-A-1
        exec-once = swaync
        exec-once = waybar
        exec-once = wl-gammarelay-rs

        ## Application Window Rules
        #windowrule=float,*(zoom)*
        windowrule=float,^(pavucontrol)$
        windowrule=float,^(virt-manager)$
        windowrule=float,^(zenity)$
        windowrulev2 = float,class:^(thunderbird)$,title:^(.*)(Reminder)(.*)$
        windowrulev2 = float,class:^(thunderbird)$,title:^About(.*)$
        windowrulev2 = float,class:^(thunderbird)$,title:^(Check Spelling)$
        windowrulev2 = monitor HDMI-A-1,class:(swayosd)
        windowrulev2 = float,title:^Zoom - Licensed Account$
        windowrulev2 = size 360 690,title:^Zoom - Licensed Account$
        windowrulev2 = float,title:^as_toolbar$
        # Zoom Sharing
        windowrulev2 = workspace 1,class:(thunderbird)$
        windowrulev2 = workspace 3,class:(^Ferdium)$

        # make Firefox PiP window floating and sticky
        windowrulev2 = float, title:^(Picture-in-Picture)$
        windowrulev2 = pin, title:^(Picture-in-Picture)$

        # throw sharing indicators away
        windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
        windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

        # idle inhibit while watching videos
        windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
        windowrulev2 = idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$
        windowrulev2 = idleinhibit fullscreen, class:^(firefox)$

        # fix xwayland apps
        windowrulev2 = rounding 0, xwayland:1, floating:1
        windowrulev2 = center, class:^(.*jetbrains.*)$, title:^(Confirm Exit|Open Project|win424|win201|splash)$
        windowrulev2 = size 640 400, class:^(.*jetbrains.*)$, title:^(splash)$

        layerrule = blur, ^(gtk-layer-shell|anyrun)$
        layerrule = ignorezero, ^(gtk-layer-shell|anyrun)$

        # UI
        general {
            gaps_in = 5
            gaps_out = 10
            border_size = 2
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)
            layout = dwindle
        }

        decoration {
            rounding = 5
          blur {
            enabled = true
            size = 3
            passes = 1
            new_optimizations = true
          }
          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
        }

        animations {
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 5, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 7, default
          enabled=1
          bezier=overshot,0.05,0.9,0.1,1.1
          bezier=overshot,0.13,0.99,0.29,1.1
          animation = windowsMove, 1, 5, myBezier
          animation = windowsOut, 1, 5, myBezier
          animation=border,1,10,default
          animation = fade, 1, 5, default
          animation=workspaces,1,4,overshot,slidevert
        }

        ## Layouts
        dwindle {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = yes # you probably want this
        }

        master {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_is_master = true
        }

        # Keybinds
        $mainMod = SUPER
        bind = $mainMod, D, exec, pkill rofi || rofi -combi-modi window,drun,ssh,run -show combi -show-icons
        bind = $mainMod, J, togglesplit, # dwindle
        bind = $mainMod, P, pseudo,      # dwindle
        bind = $mainMod, Return, exec, kitty
        bind = $mainMod, V, togglefloating,
        bind = $mainMod, mouse:274, killactive # Middle Mouse
        bind = $mainMod,F,fullscreen
        bind = $mainMod,space,pseudo,
        bind = SUPER_SHIFT, E, exec, pkill wlogout || wlogout
        bind = SUPER_SHIFT, Q, killactive
        bind = SUPER_SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy
        bind = SUPER_SHIFT, X, exec, swaylock -C ~/.config/swaylock/swaylock.conf

        ## Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

        ## Switch workspaces with mainMod + [0-9]
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        #bind = $mainMod, 10, workspace, 10

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        #bind = $mainMod SHIFT, 10, movetoworkspace, 10

        ## moving windows to other workspaces (silent)
        bind = $mainMod ALT, 1, movetoworkspacesilent,1
        bind = $mainMod ALT, 2, movetoworkspacesilent,2
        bind = $mainMod ALT, 3, movetoworkspacesilent,3
        bind = $mainMod ALT, 4, movetoworkspacesilent,4
        bind = $mainMod ALT, 5, movetoworkspacesilent,5
        bind = $mainMod ALT, 6, movetoworkspacesilent,6
        bind = $mainMod ALT, 7, movetoworkspacesilent,7
        bind = $mainMod ALT, 8, movetoworkspacesilent,8
        bind = $mainMod ALT, 9, movetoworkspacesilent,9
        #bind = $mainMod ALT, 10, movetoworkspacesilent,0

        ##
        bind = SUPERSHIFT,left,movewindow,l
        bind = SUPERSHIFT,right,movewindow,r
        bind = SUPERSHIFT,up,movewindow,u
        bind = SUPERSHIFT,down,movewindow,d

        # special workspace
        bind = $mainMod SHIFT, grave, movetoworkspace, special
        bind = $mainMod, grave, togglespecialworkspace, DP-2

        ## Scroll through existing workspaces with mainMod + scroll
        #bind = $mainMod, mouse_down, workspace, e+1
        #bind = $mainMod, mouse_up, workspace, e-1

        ## Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
        #bind=,mouse:276,workspace,e-1
        #bind=,mouse:275,workspace,e+1
        binde = SUPERCTRL,left,resizeactive,-20 0
        binde = SUPERCTRL,right,resizeactive,20 0
        binde = SUPERCTRL,up,resizeactive,0 -20
        binde = SUPERCTRL,down,resizeactive,0 20

        ## Audio
        bindl=,XF86AudioPlay,exec,playerctl play-pause
        bindl=,XF86AudioPrev,exec,playerctl previous
        bindl=,XF86AudioNext,exec,playerctl next
        bindl=,XF86AudioMedia,exec,playerctl play-pause
        bindl=,XF86AudioStop,exec,playerctl stop

        #bindle=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +1%
        bindle=,XF86AudioRaiseVolume,exec,swayosd --output-volume 1 --max-volume=100
        #bindle=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -1%
        bindle=,XF86AudioLowerVolume,exec,swayosd --output-volume -1
        #bindl=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle
        bindl=,XF86AudioMute,exec,swayosd --output-volume mute-toggle

        ## Turn off animations / game mode
        bind = WIN, F1, exec, ~/.config/hypr/gamemode.sh

        ## Clipboard
        exec-once = wl-paste --type text --watch cliphist store #Stores only text data
        exec-once = wl-paste --type image --watch cliphist store #Stores only image data
        bind = SUPER, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
      '';
    };

    xdg.configFile."hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/background/left.jpg
      preload = ~/.config/hypr/background/middle.jpg
      preload = ~/.config/hypr/background/right.jpg

      wallpaper = HDMI-A-1,~/.config/hypr/background/right.jpg
      wallpaper = DP-2,~/.config/hypr/background/middle.jpg
      wallpaper = DP-3,~/.config/hypr/background/left.jpg
    '';

    xsession = {
      enable = true;
      scriptPath = ".hm-xsession";
      windowManager.command = ''
        #export MOZ_ENABLE_WAYLAND=1
        export NIXOS_OZONE_WL=1
        export WLR_RENDERER=vulkan
        export XDG_SESSION_TYPE=wayland
        #export XDG_SESSION_DESKTOP=Hyprland
        #export XDG_CURRENT_DESKTOP=Hyprland
        export CLUTTER_BACKEND="wayland"
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_QPA_PLATFORM=wayland
        #export ECORE_EVAS_ENGINE=wayland-egl
        #export ELM_ENGINE=wayland_egl
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
        #export NO_AT_BRIDGE=1
        export GDK_BACKEND=wayland
        Hyprland
      '';
    };
  };
}
