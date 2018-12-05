local awful = require("awful")
local gears = require("gears")
local xrandr = require("utils.xrandr")
local binding = require("utils.binding")
local tagUtils = require("utils.tag")
local wibarUtils = require("utils.wibar")
local wiboxUtils = require("utils.wibox")
local layoutUtils = require("utils.layout")
local clientUtils = require("utils.client")
local commandUtils = require("utils.command")
local screenshotUtils = require("utils.screenshot")

local environment = {
    awesome = awesome,
    awful = awful,
    tag = tagUtils,
    wibar = wibarUtils,
    wibox = wiboxUtils,
    layout = layoutUtils,
    client = clientUtils,
    command = commandUtils,
    screenshot = screenshotUtils,
    xrandr = xrandr,
    widget_manager = WIDGET_MANAGER,
}

-- TODO: instead of expecting globals, maybe we just inject environment when we ask for keybindings
local keys = binding.createKeys(CONFIG.keybindings, environment)
local globalKeys = gears.table.join(unpack(keys))

-- Global Key Bindings
globalKeys = gears.table.join(globalKeys,
    -- Volume
    awful.key({}, "XF86AudioMute", function() WIDGET_MANAGER:toggleMute() end),
    awful.key({}, "XF86AudioLowerVolume", function() WIDGET_MANAGER:changeVolume("-", CONFIG.volume.change.normal) end),
    awful.key({}, "XF86AudioRaiseVolume", function() WIDGET_MANAGER:changeVolume("+", CONFIG.volume.change.normal) end),
    awful.key({SHIFT}, "XF86AudioLowerVolume", function() WIDGET_MANAGER:changeVolume("-", CONFIG.volume.change.small) end),
    awful.key({SHIFT}, "XF86AudioRaiseVolume", function() WIDGET_MANAGER:changeVolume("+", CONFIG.volume.change.small) end),

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp", function() changeBrightness("+", CONFIG.brightness.change.normal) end),
    awful.key({}, "XF86MonBrightnessDown", function() changeBrightness("-", CONFIG.brightness.change.normal) end),
    awful.key({SHIFT}, "XF86MonBrightnessUp", function() changeBrightness("+", CONFIG.brightness.change.small) end),
    awful.key({SHIFT}, "XF86MonBrightnessDown", function() changeBrightness("-", CONFIG.brightness.change.small) end)
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
