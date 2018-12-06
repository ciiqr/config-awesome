local gears = require("gears")
local binding = require("utils.binding")

local environment = {
    awesome = awesome,
    awful = require("awful"),
    tag = require("actions.tag"),
    wibar = require("actions.wibar"),
    wibox = require("actions.wibox"),
    layout = require("actions.layout"),
    client = require("actions.client"),
    command = require("actions.command"),
    screenshot = require("actions.screenshot"),
    popup = require("actions.popup"),
    xrandr = require("utils.xrandr"),
    volume = require("system.volume"),
    brightness = require("system.brightness"),
}

-- Global Key Bindings
local keys = binding.createKeys(CONFIG.keybindings, environment)
return gears.table.join(unpack(keys))

-- TODO: move, ie. keybindings.global,
