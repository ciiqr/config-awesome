local gears = require("gears")
local binding = require("utils.binding")

local environment = {
    awesome = awesome,
    awful = require("awful"),
    client = require("actions.client"),
    command = require("actions.command"),
    layout = require("actions.layout"),
    popup = require("actions.popup"),
    screenshot = require("actions.screenshot"),
    tag = require("actions.tag"),
    wibar = require("actions.wibar"),
    wibox = require("actions.wibox"),
    xrandr = require("utils.xrandr"),
    brightness = require("system.brightness"),
    volume = require("system.volume"),
}

-- Global Key Bindings
local keys = binding.createKeys(CONFIG.keybindings, environment)
return gears.table.join(table.unpack(keys))
