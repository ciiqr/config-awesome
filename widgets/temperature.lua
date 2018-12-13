local gears = require("gears")
local textbox = require("wibox.widget.textbox")
local mousebindings = require("mousebindings")
local temperature = require("system.temperature")

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

    -- markup
    self.markup = config.text or ''

    -- update every X seconds
    self.updateTimer = gears.timer({timeout = config.interval})
    self.updateTimer:connect_signal("timeout", function() self:update() end)
    self.updateTimer:start()

    -- TODO: move to config
    -- signals
    self:connect_signal("button::press", function() self:update() end)

    -- first update
    self:update()
end

function M:update()
    local displayValue = temperature.get()
    local markup = string.format(self.markup, displayValue)

    self:set_markup(markup)
end

return setmetatable(M, {__call = construct})
