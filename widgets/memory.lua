local vicious = require("vicious")
local textbox = require("wibox.widget.textbox")
local mousebindings = require("mousebindings")

local M = {}; M.__index = M

local function construct(_, config)
    local self = textbox()
    setmetatable(self, M)

    self:init(config)

    return self
end

function M:init(config)
    -- only matters on vertical wiboxes
    self:set_align("center")

    -- register vicious
    vicious.register(self, vicious.widgets.mem, config.text or '', config.interval)

    -- buttons
    local buttons = mousebindings.widget(config.mousebindings)
    self:buttons(buttons)
end

return setmetatable(M, {__call = construct})
