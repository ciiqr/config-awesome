local awful = require("awful")

local tag = {}

function tag.viewFirst()
    local tags = awful.screen.focused().tags
    local tag = tags[1]
    if tag then
        tag:view_only()
    end
end

function tag.viewLast()
    local tags = awful.screen.focused().tags
    local tag = tags[#tags]
    if tag then
        tag:view_only()
    end
end

function tag.increaseMwfact(add)
    local new_mwfact = awful.screen.focused().selected_tag.master_width_factor + add
    -- Only change the mwfact if it's not going to make things invisible
    if new_mwfact < 1 and new_mwfact > 0 then
        awful.tag.incmwfact(add, t)
    end
end

return tag
