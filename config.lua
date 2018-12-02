return {
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
        }
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
    startup = {
        programs = {
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
        editor = "sublime",
        graphicalSudo = "gksudo",
        sleep = "~/.scripts/power.sh suspend",
        screenshot = "scrot ~/Dropbox/Screenshots/$(date '+%Y-%m-%d-%T')-$(lsb_release -sc).png",
        screenshotSelect = "gm import ~/Dropbox/Screenshots/$(date '+%Y-%m-%d-%T')-$(lsb_release -sc).png",
        screenInvert = "xcalib -i -a",
        fileOpener = "xdg-open \"$(locate \"\" | dmenu -i -p Open -l 20 -fn \"Nimbus Sans L-10\")\"",
        windowSwitcher = "rofi -modi window -show",
        isRunning = "is-running",
        setWallpaper = "feh --xinerama-index {screen} --randomize --bg-fill {directory}/*",
        ipInfo = "urxvt -e bash -c 'ip addr show; cat'",
        networkTraffic = "urxvt -e bash -c 'sudo nethogs {device}'",
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
    },
    keybindings = {
        -- awesome
        ["Super + Ctrl + r"] = "awesome.restart",
        -- popups
        ["Super + Shift + t"] = {
            action = "WIDGET_MANAGER.togglePopup",
            args = {"terminal"}
        },
        ["Super + Shift + n"] = {
            action = "WIDGET_MANAGER.togglePopup",
            args = {"note"}
        },
        ["Super + Shift + c"] = {
            action = "WIDGET_MANAGER.togglePopup",
            args = {"cpu"}
        },
        ["Super + Shift + m"] = {
            action = "WIDGET_MANAGER.togglePopup",
            args = {"mem"}
        },
        ["Super + Shift + k"] = {
            action = "WIDGET_MANAGER.togglePopup",
            args = {"keepass"}
        },
    },
}
