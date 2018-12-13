local textclock = require("wibox.widget.textclock")
local cal = require("widgets.cal")

local M = {}; M.__index = M

local function construct(_, config)
    local self = textclock(config.text, config.interval)
    setmetatable(self, M)

    self:init(config)

    return self
end

function M:init(config)
    -- add popup calendar
    cal.register(self)
end

return setmetatable(M, {__call = construct})
