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
        taskManagerMem = "sudo htop --delay 5 --sort-key PERCENT_MEM",
        taskManagerCpu = "sudo htop --delay 5 --sort-key PERCENT_CPU",
        isRunning = "is-running",
        setWallpaper = "feh --xinerama-index {screen} --randomize --bg-fill {directory}/*",
        ipInfo = "urxvt -e bash -c 'ip addr show; cat'",
        networkTraffic = "urxvt -e bash -c 'sudo nethogs {device}'",
    },
}
