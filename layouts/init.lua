local awful = require("awful")
local thrizen = require("layouts.thrizen")

local layouts = {}

function layouts.init()
    -- TODO: move to config
    awful.layout.layouts = {
        thrizen,
        awful.layout.suit.tile,
        awful.layout.suit.fair,
    }
end

return layouts
