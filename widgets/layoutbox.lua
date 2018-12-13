local layoutbox = require("awful.widget.layoutbox")
local mousebindings = require("mousebindings")

local M = {}; M.__index = M

local function construct(_, config, screen)
    local self = layoutbox(screen)
    setmetatable(self, M)

    self:init(config)

    return self
end

function M:init(config)
    -- buttons
    local buttons = mousebindings.widget(config.mousebindings)
    self:buttons(buttons)
end

return setmetatable(M, {__call = construct})
