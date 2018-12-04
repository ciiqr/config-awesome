local awful = require("awful")

local client = {}

function client.viewNext()
    awful.client.focus.byidx(FORWARDS)
end

function client.viewPrev()
    awful.client.focus.byidx(BACKWARDS)
end

return client
