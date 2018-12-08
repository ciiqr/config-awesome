local awful = require("awful")
local thrizen = require("layouts.thrizen")

local layouts = {}

function layouts.init()
    awful.layout.layouts = {
        thrizen,
        awful.layout.suit.tile,
        awful.layout.suit.fair,
    }
end

return layouts
