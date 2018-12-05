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
local volume = require("system.volume")
local brightness = require("system.brightness")

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
    volume = volume,
    brightness = brightness,
    widget_manager = WIDGET_MANAGER,
}

-- Global Key Bindings
local keys = binding.createKeys(CONFIG.keybindings, environment)
local globalKeys = gears.table.join(unpack(keys))

-- TODO: move to config
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
