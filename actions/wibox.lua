local awful = require("awful")

local wibox = {}

local function toggleByName(name)
    local screen = awful.screen.focused()
    local wibox = screen[name .. "Wibox"]
    wibox.visible = not wibox.visible
end

function wibox.toggle(...)
    for i, name in ipairs({...}) do
        toggleByName(name)
    end
end

return wibox
