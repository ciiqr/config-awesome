local awful = require("awful")

local wibar = {}

local function toggleByName(name)
    local screen = awful.screen.focused()
    local wibox = screen[name .. "Wibar"]
    wibox.visible = not wibox.visible

    -- TODO: Consider whether I want this...
    -- Adjust the sysInfoWibox's height when the top/bottom wiboxes are resized
    -- TODO: Move this to the signal handler for "property::visible"
    -- OR more reasonably "property::workarea" of the screen
    local position = awful.wibar.get_position(wibox) -- TODO: deprecated: awful.wibar.get_position
    if position == "top" or position == "bottom" then
        screen.sysInfoWibox.y = screen.workarea.y
        screen.sysInfoWibox.height = screen.workarea.height
    end
end

function wibar.toggle(...)
    for i, name in ipairs({...}) do
        toggleByName(name)
    end
end

return wibar
