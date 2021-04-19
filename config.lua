return {
    plugins = {
        "theme",
        "layout",
        "keybindings",
        "rules",
        "events",
        "screens",
        "programs",
    },
    theme = {
        colourScheme = "sea",
        wallpapers = {
            normalPath = "{theme_path}/backgrounds",
            resolutionPath = "~/.wallpapers/{width}x{height}",
        },
    },
    layout = {
        layouts = {
            'layout.thrizen',
            'awful.layout.suit.tile',
            'awful.layout.suit.fair',
        },
    },
    screens = {
        tags = {"➊","➋","➌","➍","➎"}
    },
    widgets = {
        clock = {
            text = '<span foreground="#94738c">%A, %B %d</span>  <span foreground="#ecac13">%I:%M %p</span>',
            interval = 10,
        },
        temperature = {
            text = '<span weight="bold">%s°</span>',
            interval = 10,
        },
        volume = {
            text = '<span foreground="#ffaf5f" weight="bold">%s</span>',
            mousebindings = {
                ["ScrollUp"] = {action = "volume.change", args = {"-", 1}},
                ["ScrollDown"] = {action = "volume.change", args = {"+", 1}},
                ["Left"] = {action = "popup.toggle", args = {"audio"}},
            },
        },
        memory = {
            text = '<span fgcolor="#138dff" weight="bold">$1% $2MB</span>', --DFDFDF
            interval = 13,
            mousebindings = {
                ["Left"] = {action = "popup.toggle", args = {"mem"}},
            },
        },
        cpu = {
            mousebindings = {
                ["Left"] = {action = "popup.toggle", args = {"cpu"}},
            },
        },
        ip = {
            mousebindings = {
                ["Left"] = {action = "command.run", args = {"ipInfo"}},
            },
        },
        layoutbox = {
            mousebindings = {
                ["Left"] = "layout.viewNext",
                ["Right"] = "layout.viewPrev",
            },
        },
        netusage = {
            text = '<span foreground="#97D599" weight="bold">↑${%s up_mb}</span> <span foreground="#CE5666" weight="bold">↓${%s down_mb}</span>', --#585656
            interval = 1,
        },
        battery = {
            text = '<span foreground="#ffcc00" weight="bold">$1$2%$3</span>', --585656
            interval = 120,
            warning = {
                low = 10,
                critical = 5,
            },
        }
    },
    -- TODO: hmm...
    clients = {
        sublime = {
            rules = {
                ["awesome, lib"] = 7,
                ["machines"] = 7,
            }
        }
    },
    brightness = {
        change = {
            normal = 10,
            small = 1,
        },
    },
    volume = {
        change = {
            normal = 10,
            small = 1,
        },
    },
    programs = {
        startup = {
            -- Composition Manager (Transparency, Inactive Window Dimming, Visual Glitch Fix)
            "picom",

            -- Daemons
            "spacefm -d",

            -- Launchers
            "albert",

            -- Tray's
            "redshift-gtk",
            "nm-applet",
            -- "syncthing-gtk --minimized",
            "syncthingtray",
            "blueman-applet",
        },
    },
    commands = {
        terminal = "alacritty",
        browser = "gtk-launch google-chrome",
        fileManager = "spacefm",
        rootFileManager = "gksudo spacefm",
        editor = "sublime",
        rootEditor = "gksudo sublime",
        sleep = "~/.scripts/power.sh suspend",
        screenshot = "scrot ~/Screenshots/$(date '+%Y-%m-%d-%H-%M-%S')-$(lsb_release -sc).png && notify-send -t 1000 'Screenshot Taken'",
        screenshotSelect = "gm import ~/Screenshots/$(date '+%Y-%m-%d-%H-%M-%S')-$(lsb_release -sc).png && notify-send -t 1000 'Screenshot Taken'",
        fileOpener = "xdg-open \"$(locate \"\" | dmenu -i -p Open -l 20 -fn \"Nimbus Sans L-10\")\"",
        windowSwitcher = "rofi -modi window -show",
        setWallpaper = "feh --xinerama-index {screen} --randomize --bg-fill {directory}/*",
        ipInfo = "alacritty -e bash -c 'ip addr show; cat'",
        networkTraffic = "alacritty -e bash -c 'sudo nethogs {device}'",
        pastePrimary = "xdotool click 2",
    },
    popups = {
        -- TODO: consider making the command configurable via config key
        -- TODO: reasonable default for options.name, options.height, options.width
        {
            name = "terminal",
            geometry = {height = 0.35, width = 0.5},
            options = {app = "alacritty", argname = "--title %s"},
        },
        {
            name = "note",
            geometry = {height = 0.35, width = 0.5},
            options = {app = "leafpad", argname = "--name=%s", name = "LEAFPAD_QUICK_NOTE"},
        },
        {
            name = "cpu",
            geometry = {height = 0.75, width = 0.5, horiz = "right"},
            options = {app = "alacritty", argname = "--title %s", extra = "-e sudo htop --delay 5 --sort-key PERCENT_CPU", name = "POPUP_CPU"},
        },
        {
            name = "mem",
            geometry = {height = 0.75, width = 0.5, horiz = "left"},
            options = {app = "alacritty", argname = "--title %s", extra = "-e sudo htop --delay 5 --sort-key PERCENT_MEM", name = "POPUP_MEM"},
        },
        {
            name = "keepass",
            geometry = {height = 0.5, width = 0.5},
            options = {app = "keepassx2", name = "keepassx2"},
        },
        {
            name = "audio",
            geometry = {height = 0.5, width = 0.3333, horiz = "right"},
            options = {app = "pavucontrol", name = "AUDIO_POPUP", argname = "--name=%s"},
        },
    },
    keybindings = {
        -- Switch Between Tags
        ["Super + Escape"] = "awful.tag.history.restore",
        ["Ctrl + Alt + Left"] = "awful.tag.viewprev",
        ["Ctrl + Alt + Right"] = "awful.tag.viewnext",
        ["Ctrl + Alt + Up"] = "tag.viewFirst",
        ["Ctrl + Alt + Down"] = "tag.viewLast",
        -- Toggle Bars
        ["Super + ["] = {action = "wibar.toggle", args = {"top", "bottom"}},
        ["Super + ]"] = {action = "wibar.toggle", args = {"bottom"}},
        -- Toggle Boxes
        ["Super + c"] = {action = "wibox.toggle", args = {"allWindows", "sysInfo"}},
        -- Switch Layout
        ["Super + space"] = "layout.viewNext",
        ["Super + Shift + space"] = "layout.viewPrev",
        -- Switch Window
        ["Super + Tab"] = "client.viewNext",
        ["Super + Shift + Tab"] = "client.viewPrev",
        ["Super + Next"] = "client.viewNext",
        ["Super + Prior"] = "client.viewPrev",
        -- ClientRestore
        ["Super + Ctrl + Up"] = "client.restore",
        -- Maximize
        ["Super + Up"] = "layout.viewMaximized",
        -- Revert Maximize
        ["Super + Down"] = "layout.revertMaximized",
        -- Sleep
        ["XF86Sleep"] = {action = "command.run", args = {"sleep"}},
        ["Super + Ctrl + q"] = {action = "command.run", args = {"sleep"}},
        -- Change Position
        ["Super + Left"] = "client.swapPrev",
        ["Super + Right"] = "client.swapNext",
        -- Move Middle
        ["Super + Shift + Left"] = {action = "tag.increaseMwfact", args = {-0.05}},
        ["Super + Shift + Right"] = {action = "tag.increaseMwfact", args = {0.05}},
        -- Switch between screens
        ["Super + F1"] = {action = "awful.screen.focus", args = {1}},
        ["Super + F2"] = {action = "awful.screen.focus", args = {2}},
        ["Super + F3"] = {action = "awful.screen.focus", args = {3}},
        -- Launcher Style Popups
        ["Super + w"] = {action = "command.run", args = {"fileOpener"}},
        ["Super + s"] = {action = "command.run", args = {"windowSwitcher"}},
        -- Programs
        ["Super + t"] = {action = "command.run", args = {"terminal"}},
        ["Super + Enter"] = {action = "command.run", args = {"fileManager"}},
        ["Super + Shift + Enter"] = {action = "command.run", args = {"rootFileManager"}},
        ["Super + o"] = {action = "command.run", args = {"editor"}},
        ["Super + Shift + o"] = {action = "command.run", args = {"rootEditor"}},
        ["Super + u"] = {action = "command.run", args = {"browser"}},
        -- awesome
        ["Super + Ctrl + r"] = "awesome.restart",
        -- Volume
        ["XF86AudioMute"] = "volume.toggleMute",
        ["XF86AudioLowerVolume"] = {action = "volume.change", args = {"-", 10}},
        ["XF86AudioRaiseVolume"] = {action = "volume.change", args = {"+", 10}}, -- TODO: consider if want to use or get rid of: CONFIG.volume.change.normal
        ["Shift + XF86AudioLowerVolume"] = {action = "volume.change", args = {"-", 1}}, -- TODO: consider if want to use or get rid of: CONFIG.volume.change.small
        ["Shift + XF86AudioRaiseVolume"] = {action = "volume.change", args = {"+", 1}},
        -- Brightness
        ["XF86MonBrightnessUp"] = {action = "brightness.change", args = {"+", 10}},
        ["XF86MonBrightnessDown"] = {action = "brightness.change", args = {"-", 10}}, -- TODO: change to use CONFIG.brightness.change.normal
        ["Shift + XF86MonBrightnessUp"] = {action = "brightness.change", args = {"+", 1}}, -- TODO: change to use CONFIG.brightness.change.small
        ["Shift + XF86MonBrightnessDown"] = {action = "brightness.change", args = {"-", 1}},
        -- Screenshot
        ["Print"] = {action = "command.run", args = {"screenshot"}},
        ["Super + Print"] = {action = "command.run", args = {"screenshotSelect"}},
        -- Copypasta
        ["Insert"] = {action = "command.run", args = {"pastePrimary"}}, -- If I stop using, put 'keycode 118 = ' back in .Xmodmap
        -- Cycle Displays
        ["Super + F11"] = "xrandr", -- TODO: refactor xrandr module so this command can be: xrandr.cycle
        -- Popups
        ["Super + Shift + t"] = {action = "popup.toggle", args = {"terminal"}},
        ["Super + Shift + n"] = {action = "popup.toggle", args = {"note"}},
        ["Super + Shift + c"] = {action = "popup.toggle", args = {"cpu"}},
        ["Super + Shift + m"] = {action = "popup.toggle", args = {"mem"}},
        ["Super + Shift + k"] = {action = "popup.toggle", args = {"keepass"}},
        -- Tag keys
        ["Ctrl + Alt + {1-9}"] = "tag.viewIndex",
        ["Super + Shift + {1-9}"] = "tag.toggleIndex",
    },
    client = {
        keybindings = {
            -- Move Between Tags
            ["Super + Alt + Left"] = "client.moveLeftAndFollow",
            ["Super + Alt + Right"] = "client.moveRightAndFollow",
            ["Super + Alt + Up"] = "client.moveToFirstTagAndFollow",
            ["Super + Alt + Down"] = "client.moveToLastTagAndFollow",
            ["Super + Alt + {1-9}"] = "client.moveToTagAndFollow",
            -- Toggle Tags
            ["Super + Ctrl + Alt + {1-9}"] = "client.toggleTag", -- TODO: Change to Ctrl, Alt Shift to be more like mod shift for toggling a tag visibility
            -- Kill
            ["Super + q"] = "client.kill",
            -- Fullscreen
            ["Super + f"] = "client.toggleFullscreen",
            -- Multi Fullscreen
            ["Super + Shift + f"] = "client.toggleMultiFullscreen",
            -- Minimize
            ["Super + Ctrl + Down"] = "client.minimize",
            -- Floating
            ["Super + Alt + space"] = "client.toggleFloating",
            -- Sticky
            ["Super + Alt + s"] = "client.toggleSticky",
            -- PIP
            ["Super + Alt + p"] = "client.togglePip",
            -- Debug Info
            ["Super + g"] = "client.debug",
        },
        mousebindings = {
            ["Left"] = "client.focus",
            ["Super + Left"] = "awful.mouse.client.move",
            -- ["Middle"] = "awful.mouse.client.move", -- TODO: I can't currently use this because it conflicts with 'Insert' paste... (if I can convince Insert to be been as shift+Insert then maybe I can enable this...)
            ["Super + Right"] = "awful.mouse.client.resize",
            -- Prevent ctrl-scroll zoom
            ["Ctrl + ScrollUp"] = "noop",
            ["Ctrl + ScrollDown"] = "noop",
        },
        pip = {
            width = 0.3333,
            height = 0.3333,
        },
    },
    -- TODO: decide the structure for app specific keybindings
    chromium = {
        keybindings = {
            ["Ctrl + q"] = "chromium.quit",
        },
    },
}
