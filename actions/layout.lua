local awful = require("awful")
local gears = require("gears")

local layout = {}

local function viewRelative(direction)
    -- if maximized to go first/last layout
    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if tag.layout == awful.layout.suit.max then
        layout.revertMaximized()
    else
        awful.layout.inc(direction)
    end
end

function layout.viewNext()
    viewRelative(1)
end

function layout.viewPrev()
    viewRelative(-1)
end

function layout.viewMaximized()
    -- If no layout stored then
    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if (not tag.preMaximizeLayout) then
        -- Store current layout
        tag.preMaximizeLayout = tag.layout
        tag.preMaximizeLayouts = gears.table.clone(tag.layouts, false)
        -- Change to Maximized
        tag.layout = awful.layout.suit.max
    end
end
function layout.revertMaximized()
    -- Revert Maximize
    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if (tag.layout == awful.layout.suit.max) then
        -- Restore layout
        tag.layout = tag.preMaximizeLayout
        tag.layouts = tag.preMaximizeLayouts
        -- Reset cached layouts
        tag.preMaximizeLayout = nil
        tag.preMaximizeLayouts = nil
    end
end

return layout
