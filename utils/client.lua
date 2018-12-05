local awful = require("awful")

local client = {}

function client.viewNext()
    awful.client.focus.byidx(FORWARDS)
end

function client.viewPrev()
    awful.client.focus.byidx(BACKWARDS)
end

function client.swapNext()
    awful.client.swap.byidx(FORWARDS)
end

function client.swapPrev()
    awful.client.swap.byidx(BACKWARDS)
end

function client.restore()
    local c = awful.client.restore()
    -- Ensure unminimized client is the new focused client
    if c then
        client.focus = c
    end
end

return client
