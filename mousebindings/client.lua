local gears = require("gears")
local binding = require("utils.binding")

-- Buttons
local environment = {
    awful = require("awful"),
    noop = function()end,
    client = require("actions.client"),
}

-- Client Mouse Bindings
local buttons = binding.createMouseBindings(CONFIG.client.mousebindings, environment)
return gears.table.join(unpack(buttons))
