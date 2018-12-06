local awful = require("awful")
local gears = require("gears")
local binding = require("utils.binding")

local environment = {
    awesome = awesome,
    awful = awful,
    tag = require("utils.tag"),
    wibar = require("utils.wibar"),
    wibox = require("utils.wibox"),
    layout = require("utils.layout"),
    client = require("actions.client"),
    command = require("utils.command"),
    screenshot = require("utils.screenshot"),
    popup = require("utils.popup"),
    xrandr = require("utils.xrandr"),
    volume = require("system.volume"),
    brightness = require("system.brightness"),
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

-- TODO: move, ie. keybindings.global,
