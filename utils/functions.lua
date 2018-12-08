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
function setupSignals()
    -- Screen Signals
    capi.screen.connect_signal("property::geometry", screenPropertyGeometry)
    capi.screen.connect_signal("added", screenInit)

    -- Client Signals
    client.connect_signal("manage", manageClient)
    client.connect_signal("focus", clientDidFocus)
    client.connect_signal("unfocus", clientDidLoseFocus)
    client.connect_signal("property::floating", clientDidChangeFloating)
    client.connect_signal("mouse::enter", clientDidMouseEnter)
    setupClientRequestActivate()
end

function setupClientRequestActivate()
    -- from: http://new.awesomewm.org/apidoc/documentation/90-FAQ.md.html
    client.disconnect_signal("request::activate", awful.ewmh.activate)
    function awful.ewmh.activate(c)
        if c:isvisible() then
            client.focus = c
            c:raise()
        end
    end
    client.connect_signal("request::activate", awful.ewmh.activate)
end

local function transientShouldBeSticky(c)
    return (c.name and c.name:find("LEAFPAD_QUICK_NOTE")) -- or
end

function manageClient(c)
    -- When first created

    -- TODO: need to confirm this is fine...
    -- if not startup then
    --     -- determines order of new clients
    --     awful.client.setslave(c)
    --     -- Position
    --     if not c.size_hints.user_position and not c.size_hints.program_position then
    --         awful.placement.no_overlap(c)
    --         awful.placement.no_offscreen(c)
    --     end
    -- end
    if not awesome.startup then
        awful.client.setslave(c)
    end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Subwindows Sticky
    if c.transient_for and transientShouldBeSticky(c) then
        notify_send("Transient's UNITE!")
        c.sticky = true
    end

    -- TODO: 2 below, this is also in property-change/event-handlers & it would be nice if it was only in one location...
    -- If a client is automatically floating, make it ontop
    clientDidChangeFloating(c)

    if client.focus == c then
        clientDidFocus(c)
    end
end

function clientDidFocus(c)
    c.border_color = beautiful.border_focus
    c:raise()
end

function clientDidLoseFocus(c)
    c.border_color = beautiful.border_normal
end

function clientDidChangeFloating(c)
    c.ontop = c.floating and not c.fullscreen
end

function clientDidMouseEnter(c)
    if not c.minimized then
        clientShouldAttemptFocus(c)
    end
end

function screenPropertyGeometry(s)
    screenSetWallpaper(s)
end

function clientShouldAttemptFocus(c)
    -- NOTE: Experimental support for not changing focus from transient back to it's parent
    -- NOTE: If there is another client on screen then we can still switch to that client then back to the parent...
    -- NOTE: ALSO: Experimental support for not changing focus to fullscreen windows automatically, intended to help with the fact that fullscreen windows are displayed over top of wiboxes
    -- NOTE: Also with the fullscreen note above, the or current client floating means that I can quickly switch between a fullscreen window & say my calculator
    -- DEFAULT: and awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    if (not client.focus) or awful.client.focus.filter(c) and ((not client.focus) or client.focus.transient_for ~= c) and (not c.fullscreen or client.focus.floating) then
        client.focus = c
    end
end

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
        theme_path = THEME_PATH,
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

-- Programs
function run_once(prg)
    awful.spawn.with_shell('~/.scripts/run-once.sh ' .. prg)
end

function startupPrograms()
    for _,program in ipairs(CONFIG.startup.programs) do
        run_once(program)
    end
end

-- Clients
function toggleClient(c)
  if c == client.focus then
    c.minimized = true
  else
    c.minimized = false
    if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
    end
    client.focus = c
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
