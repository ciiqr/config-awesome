local awful = require("awful")
local gears = require("gears")
local vicious = require("vicious")
local textbox = require("wibox.widget.textbox")
local network = require("system.network")

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

    local networkDevice = network.getPrimaryDevice()
    local markup = string.format(config.text or '', networkDevice, networkDevice)

    -- register vicious
    vicious.register(self, vicious.widgets.net, markup, config.interval)

    -- TODO: move to config
    -- buttons
    local networkTrafficCmd = evalTemplate(CONFIG.commands.networkTraffic, {
        device = networkDevice,
    })
    self:buttons(gears.table.join(
        awful.button({}, 1, function() awful.spawn(networkTrafficCmd) end)
    ))
end

return setmetatable(M, {__call = construct})
