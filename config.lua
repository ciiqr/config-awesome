return {
    plugins = {
        "theme",
        "layouts",
        "keybindings",
        "rules",
        "events",
        "screens",
        "programs",
    },
    theme = {
        wallpapers = {
            normalPath = "{theme_path}/backgrounds",
            resolutionPath = "~/Dropbox/Wallpapers/{width}x{height}",
        },
    },
    screens = {
        tags = {"➊","➋","➌","➍","➎","➏","➐","➑","➒"}
    },
    widgets = {
        clock = {
            text = '<span foreground="#94738c">%A, %B %d</span>  <span foreground="#ecac13">%I:%M %p</span>',
        },
        temperature = {
            interval = 10,
        },
        volume = {
            mousebindings = {
                ["ScrollUp"] = {action = "volume.change", args = {"+", 1}},
                ["ScrollDown"] = {action = "volume.change", args = {"-", 1}},
                ["Left"] = {action = "popup.toggle", args = {"audio"}},
            },
        },
        memory = {
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
        layout = {
            mousebindings = {
                ["Left"] = "layout.viewNext",
                ["Right"] = "layout.viewPrev",
            },
        },
    },
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
            -- Awesome
            "compton", -- Composition Manager (Transparency, Inactive Window Dimming, Visual Glitch Fix)

            -- Daemons
            "spacefm -d",

            -- Launchers
            "albert",

            -- Tray's
            "redshift-gtk",
            "nm-applet",
            "dropbox start -i",
        },
    },
    commands = {
        terminal = "urxvt",
        fileManager = "spacefm",
        rootFileManager = "gksudo spacefm",
        editor = "sublime",
        rootEditor = "gksudo sublime",
        sleep = "~/.scripts/power.sh suspend",
        screenshot = "scrot ~/Dropbox/Screenshots/$(date '+%Y-%m-%d-%T')-$(lsb_release -sc).png",
        screenshotSelect = "gm import ~/Dropbox/Screenshots/$(date '+%Y-%m-%d-%T')-$(lsb_release -sc).png",
        fileOpener = "xdg-open \"$(locate \"\" | dmenu -i -p Open -l 20 -fn \"Nimbus Sans L-10\")\"",
        windowSwitcher = "rofi -modi window -show",
        setWallpaper = "feh --xinerama-index {screen} --randomize --bg-fill {directory}/*",
        ipInfo = "urxvt -e bash -c 'ip addr show; cat'",
        networkTraffic = "urxvt -e bash -c 'sudo nethogs {device}'",
        pastePrimary = "xdotool click 2",
    },
    popups = {
        -- TODO: consider making the command configurable via config key
        -- TODO: reasonable default for options.name, options.height, options.width
        {
            name = "terminal",
            options = {app = "urxvt", height = 0.35, width = 0.5},
        },
        {
            name = "note",
            options = {app = "leafpad", argname = "--name=%s", name = "LEAFPAD_QUICK_NOTE", height = 0.35, width = 0.5},
        },
        {
            name = "cpu",
            options = {app = "urxvt", argname = "-name %s -e ".."sudo htop --delay 5 --sort-key PERCENT_CPU", name = "QUAKE_COMMAND_TASK_MANAGER_CPU", height = 0.75, width = 0.5, horiz = "right"},
        },
        {
            name = "mem",
            options = {app = "urxvt", argname = "-name %s -e ".."sudo htop --delay 5 --sort-key PERCENT_MEM", name = "QUAKE_COMMAND_TASK_MANAGER_MEM", height = 0.75, width = 0.5, horiz = "left"},
        },
        {
            name = "keepass",
            options = {app = "keepassx2", name = "keepassx2", height = 0.75, width = 0.5},
        },
        -- TODO: fix...
        {
            name = "audio",
            options = {app = "pavucontrol", name = "Volume Control", argname = "", height = 0.75, width = 0.5},
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
        ["Super + Control + Up"] = "client.restore",
        -- Maximize
        ["Super + Up"] = "layout.viewMaximized",
        -- Revert Maximize
        ["Super + Down"] = "layout.revertMaximized",
        -- Sleep
        ["XF86Sleep"] = {action = "command.run", args = {"sleep"}},
        ["Super + Control + q"] = {action = "command.run", args = {"sleep"}},
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
        ["Print"] = "screenshot.capture",
        ["Super + Print"] = "screenshot.snip",
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
            ["Super + Ctrl + Alt + {1-9}"] = "client.toggleTag", -- TODO: Change to Control, Alt Shift to be more like mod shift for toggling a tag visibility
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
}
