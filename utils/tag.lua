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

return tag
