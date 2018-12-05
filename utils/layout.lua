local awful = require("awful")

local layout = {}

local function viewRelative(direction)
    -- if maximized to go first/last layout
    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if tag.layout == awful.layout.suit.max then
        -- Determine Index
        local index = direction == FORWARDS and 1 or #awful.layout.layouts
        --  Set Layout
        tag.layout = awful.layout.layouts[index]
        -- Clear Maximized Layout
        tag.preMaximizeLayout = nil
    else
        awful.layout.inc(direction)
    end
end

function layout.viewNext()
    viewRelative(FORWARDS)
end

function layout.viewPrev()
    viewRelative(BACKWARDS)
end

function layout.viewMaximized()
    -- If No Layout Stored Then
    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if (not tag.preMaximizeLayout) then
        -- Store Current Layout
        tag.preMaximizeLayout = tag.layout
        -- Change to Maximized
        tag.layout = awful.layout.suit.max
    end
end
function layout.revertMaximized()
    -- Revert Maximize
    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if (tag.layout == awful.layout.suit.max) then
        tag.layout = tag.preMaximizeLayout
        tag.preMaximizeLayout = nil
    end
end

return layout
