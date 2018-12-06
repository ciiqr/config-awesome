local gears = require("gears")
local binding = require("utils.binding")

local environment = {
    awesome = awesome,
    awful = require("awful"),
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
return gears.table.join(unpack(keys))

-- TODO: move, ie. keybindings.global,
