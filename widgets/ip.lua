local textbox = require("wibox.widget.textbox")
local mousebindings = require("mousebindings")
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

    -- buttons
    local buttons = mousebindings.widget(config.mousebindings)
    self:buttons(buttons)

    -- signals
    dbus.request_name("system", "org.freedesktop.NetworkManager")
    dbus.add_match("system", "interface='org.freedesktop.NetworkManager',member='PropertiesChanged'")
    dbus.connect_signal("org.freedesktop.NetworkManager", function(first, second, ...) -- Doesn't seem to be a third
        update()
    end)

    -- first update
    self:update()
end

function M:update()
    local ip = network.getIp()
    self:set_text(ip)
end

return setmetatable(M, {__call = construct})
