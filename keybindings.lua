local awful = require("awful")
local gears = require("gears")
local xrandr = require("utils.xrandr")
local binding = require("utils.binding")
local tagUtils = require("utils.tag")
local wibarUtils = require("utils.wibar")
local wiboxUtils = require("utils.wibox")
local layoutUtils = require("utils.layout")
local clientUtils = require("utils.client")

local environment = {
    awesome = awesome,
    awful = awful,
    tag = tagUtils,
    wibar = wibarUtils,
    wibox = wiboxUtils,
    layout = layoutUtils,
    client = clientUtils,
    widget_manager = WIDGET_MANAGER,
}

-- TODO: instead of expecting globals, maybe we just inject environment when we ask for keybindings
local keys = binding.createKeys(CONFIG.keybindings, environment)
local globalKeys = gears.table.join(unpack(keys))

-- Global Key Bindings
globalKeys = gears.table.join(globalKeys,
    -- ClientRestore
    awful.key({SUPER, CONTROL}, "Up", restoreClient),

    -- Maximize
    awful.key({SUPER}, "Up", switchToMaximizedLayout),
    -- Revert Maximize
    awful.key({SUPER}, "Down", revertFromMaximizedLayout),

    -- Sleep
    awful.key({}, "XF86Sleep", function() awful.spawn.with_shell(CONFIG.commands.sleep) end),
    awful.key({SUPER, CONTROL}, "q", function() awful.spawn.with_shell(CONFIG.commands.sleep) end),

    -- Change Position
    awful.key({SUPER}, "Left", function() awful.client.swap.byidx(BACKWARDS) end),
    awful.key({SUPER}, "Right", function() awful.client.swap.byidx(FORWARDS) end),

    -- Move Middle
    awful.key({SUPER, SHIFT}, "Left", function() increaseMwfact(-0.05) end),
    awful.key({SUPER, SHIFT}, "Right", function() increaseMwfact(0.05) end),
    -- awful.key({SUPER, SHIFT}, "Up", function() increaseClientWfact(-0.05, client.focus) end), -- TODO: To shift window up/down in size
    -- awful.key({SUPER, SHIFT}, "Down", function() increaseClientWfact(0.05, client.focus) end), -- TODO: To shift window up/down in size

    -- Change Number of Columns(Only on splitup side)
    awful.key({SUPER, CONTROL}, "h", function() awful.tag.incncol(FORWARDS) end),
    awful.key({SUPER, CONTROL}, "l", function() awful.tag.incncol(BACKWARDS) end),

    -- Switch beteen screens
    -- TODO: Make it depend on the number of attached screens
        -- Could just have a function that loops through the screen count & calls this the given number of times with the different numbers & joins them to a list
    -- perScreen(function(s)
    --  return awful.key({SUPER}, "F"..s, function() notify_send(s) end)
    -- end),
    awful.key({SUPER}, "F1", function() awful.screen.focus(1) end),
    awful.key({SUPER}, "F2", function() awful.screen.focus(2) end),
    awful.key({SUPER}, "F3", function() awful.screen.focus(3) end),

    -- Popups
    -- Launcher Style
    awful.key({SUPER}, "w", function() awful.spawn.with_shell(CONFIG.commands.fileOpener) end),
    awful.key({SUPER}, "s", function() awful.spawn.with_shell(CONFIG.commands.windowSwitcher) end),

    -- Programs
    awful.key({SUPER}, "t", function() awful.spawn(CONFIG.commands.terminal) end),

    awful.key({SUPER}, "Return", function() awful.spawn(CONFIG.commands.fileManager) end),
    awful.key({SUPER, SHIFT}, "Return", function() awful.spawn(CONFIG.commands.graphicalSudo.." "..CONFIG.commands.fileManager) end),

    awful.key({SUPER}, "o", function() awful.spawn.with_shell(CONFIG.commands.editor) end),
    awful.key({SUPER, SHIFT}, "o", function() awful.spawn.with_shell(CONFIG.commands.graphicalSudo.." "..CONFIG.commands.editor) end),

    -- Awesome
    -- awful.key({SUPER, CONTROL}, "r", awesome.restart),

    -- System
    -- Volume
    awful.key({}, "XF86AudioMute", function() WIDGET_MANAGER:toggleMute() end),
    awful.key({}, "XF86AudioLowerVolume", function() WIDGET_MANAGER:changeVolume("-", CONFIG.volume.change.normal) end),
    awful.key({}, "XF86AudioRaiseVolume", function() WIDGET_MANAGER:changeVolume("+", CONFIG.volume.change.normal) end),
    awful.key({SHIFT}, "XF86AudioLowerVolume", function() WIDGET_MANAGER:changeVolume("-", CONFIG.volume.change.small) end),
    awful.key({SHIFT}, "XF86AudioRaiseVolume", function() WIDGET_MANAGER:changeVolume("+", CONFIG.volume.change.small) end),

    -- Brightness
    -- TODO: only setup keybindings if brightness can be adjusted...
    awful.key({}, "XF86MonBrightnessUp", function() changeBrightness("+", CONFIG.brightness.change.normal) end),
    awful.key({}, "XF86MonBrightnessDown", function() changeBrightness("-", CONFIG.brightness.change.normal) end),
    awful.key({SHIFT}, "XF86MonBrightnessUp", function() changeBrightness("+", CONFIG.brightness.change.small) end),
    awful.key({SHIFT}, "XF86MonBrightnessDown", function() changeBrightness("-", CONFIG.brightness.change.small) end),

    -- Invert Screen
    awful.key({SUPER}, "i", function() awful.spawn.with_shell(CONFIG.commands.screenInvert) end),

    -- Print Screen
    awful.key({}, "Print", captureScreenshot),

    -- Print Screen (Select Area)
    awful.key({SUPER}, "Print", captureScreenSnip),

    -- Cycle Displays
    awful.key({SUPER}, "F11", xrandr),

    -- Pasteboard paste
    awful.key({}, "Insert", function() awful.spawn("xdotool click 2") end), -- put 'keycode 118 = ' back in .Xmodmap if I no longer use this
    awful.key({SUPER}, "Insert", pasteClipboardIntoPrimary) -- TODO: Figure out why it doesn't work
)

-- Tag Keys
-- Uses keycodes to make it works on any keyboard layout
for i = 1, #CONFIG.screens.tags do
    local iKey = "#"..(i + 9)
    globalKeys = gears.table.join(globalKeys,
        awful.key({ALT, CONTROL},       iKey, function() switchToTag(i) end),
        awful.key({SUPER, ALT},         iKey, function() moveClientToTagAndFollow(i) end),

        -- NOTE: Never Used
        awful.key({SUPER, SHIFT},       iKey, function() toggleTag(i) end),
        awful.key({SUPER, CONTROL, ALT},iKey, function() toggleClientTag(i) end)) -- TODO: Change to Control, Alt Shift to be more like mod shift for toggling a tag visibility
end

return globalKeys
