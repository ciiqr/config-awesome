local gears = require("gears")
local beautiful = require("beautiful")

local theme = {}

function theme.init()
    local path = gears.filesystem.get_configuration_dir() .. "theme/theme.lua"
    beautiful.init(path)
end

return theme
