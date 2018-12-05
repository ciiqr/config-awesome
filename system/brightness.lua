local awful = require("awful")

local brightness = {}

function brightness.change(direction, percent)
    awful.spawn.with_shell("~/.scripts/brightness.sh change " .. direction .. ' ' .. percent)
end

return brightness
