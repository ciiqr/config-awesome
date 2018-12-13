local textbox = require("wibox.widget.textbox")
local mousebindings = require("mousebindings")
local volume = require("system.volume")

local M = {}; M.__index = M

local function construct(_, config)
    local self = textbox()
    setmetatable(self, M)

    self:init(config)

    return self
end

function M:init(config)
    -- markup
    self.markup = config.text or ''

    -- buttons
    local buttons = mousebindings.widget(config.mousebindings)
    self:buttons(buttons)

    -- signals
    volume:connect_signal(volume.CHANGED, function() self:update() end)

    -- first update
    self:update()
end

function M:update()
    local displayValue = volume.isMuted() and '🔇' or '🔈 ' .. volume.getVolume()
    local markup = string.format(self.markup, displayValue)

    self:set_markup(markup)
end

return setmetatable(M, {__call = construct})
