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

        -- awesome
        ["Super + Ctrl + r"] = "awesome.restart",
        -- popups
        ["Super + Shift + t"] = {
            action = "widget_manager.togglePopup",
            args = {"terminal"}
        },
        ["Super + Shift + n"] = {
            action = "widget_manager.togglePopup",
            args = {"note"}
        },
        ["Super + Shift + c"] = {
            action = "widget_manager.togglePopup",
            args = {"cpu"}
        },
        ["Super + Shift + m"] = {
            action = "widget_manager.togglePopup",
            args = {"mem"}
        },
        ["Super + Shift + k"] = {
            action = "widget_manager.togglePopup",
            args = {"keepass"}
        },
    },
}
