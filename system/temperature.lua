local awful = require("awful")

local temperature = {}

function temperature.get()
    return trim(execForOutput("~/.scripts/temperature.sh get"))
end

return temperature
