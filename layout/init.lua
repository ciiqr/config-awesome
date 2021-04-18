local awful = require("awful")
local gears = require("gears")

local layouts = {}

function layouts.init()
    awful.layout.layouts = gears.table.map(require, CONFIG.layout.layouts)
end

return layouts
