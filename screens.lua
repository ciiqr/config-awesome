local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local popup = require("actions.popup")
local wiboxes = require("wiboxes")

local capi =
{
    screen = screen,
}

local screens = {}

function screens.init()
    for screen in capi.screen do
        screens.setup(screen)
    end
end

-- Signals
function screens.setup(s)
    -- Wallpaper
    screens.setWallpaper(s)

    -- Tags
    awful.tag(CONFIG.screens.tags, s, awful.layout.layouts[1])

    -- Popup Terminal/Process Info/Notes/etc
    popup.init(s)

    -- Wiboxes w/ Widgets
    wiboxes.setup(s)
end

function screens.setWallpaper(s)
    local resolutionPathTpl = CONFIG.theme.wallpapers.resolutionPath
    local normalPathTpl = CONFIG.theme.wallpapers.normalPath

    local resolutionPath = expandUser(evalTemplate(resolutionPathTpl, s.geometry))
    local normalPath = expandUser(evalTemplate(normalPathTpl, {
        theme_path = beautiful.theme_path,
    }))

    local wallpapersPath = (gears.filesystem.dir_readable(resolutionPath) and resolutionPath or normalPath)

    -- Random Background
    local cmd = evalTemplate(CONFIG.commands.setWallpaper, {
        screen = (s.index - 1),
        directory = wallpapersPath,
    })
    awful.spawn.with_shell(cmd)
end

return screens
