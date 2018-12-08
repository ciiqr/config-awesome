local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local popup = require("actions.popup")
local widgetManager = require("widgets.manager")

local capi =
{
    screen = screen,
    client = client,
}

function setupScreens()
    for screen in capi.screen do
        screenInit(screen)
    end
end

--Signals
function screenInit(s)
    -- Wallpaper
    screenSetWallpaper(s)

    --Tags
    awful.tag(CONFIG.screens.tags, s, awful.layout.layouts[1])

    -- Popup Terminal/Process Info/Notes/etc
    popup.init(s)

    --Wiboxes w/ Widgets
    widgetManager.initWiboxes(s)
end

--Utility
function evalTemplate(template, data)
    return template:gsub("{([%w_]+)}", data)
end
function expandUser(path)
    return path:gsub('~', os.getenv('HOME'))
end

function screenSetWallpaper(s)
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

--Naughty
function notify_send(text, timeout, preset)
    naughty.notify({
        preset = preset or naughty.config.presets.normal,
        text = text,
        screen = capi.screen.count(),
        timeout = timeout or 0
    })
end

-- Clients
function toggleClient(c)
  if c == capi.client.focus then
    c.minimized = true
  else
    c.minimized = false
    if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
    end
    capi.client.focus = c
  end
end

if not table.indexOf then
    function table.indexOf(haystack, needle)
        for index, value in ipairs(haystack) do
            if value == needle then
                return index
            end
        end

        return nil
    end
end

-- trim string
-- SOURCE: http://lua-users.org/wiki/StringTrim#trim6
function trim(s)
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function execForOutput(command)
    local file = assert(io.popen(command))
    local output = file:read("*all")

    file:close()
    return output
end
