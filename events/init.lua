local screen = require("events.screen")
local client = require("events.client")

local events = {}

function events.init()
    screen.init()
    client.init()
end

return events
