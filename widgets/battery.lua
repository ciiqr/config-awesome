local naughty = require("naughty")
local vicious = require("vicious")
local textbox = require("wibox.widget.textbox")
local battery = require("system.battery")

local M = {}; M.__index = M

-- TODO: Make so we can update from acpi, ie. DBus acpi notifications
local function customWrapper(format, warg)
    local retval = vicious.widgets.bat(format, warg) -- state, percent, time, wear
    local batteryPercent = retval[2]

    if retval[3] == "N/A" then -- Time
        retval[3] = ""
    else
        retval[3] = " "..retval[3]
    end

    -- On Battery
    if retval[1] == "−" then
        local function notifyBatteryWarning(level)
            notifySend(level.." Battery: "..batteryPercent.."% !", 0, naughty.config.presets.critical)
        end
        -- Low Battery
        -- TODO: make this less dumb about getting config
        if batteryPercent < CONFIG.widgets.battery.warning.critical then
            notifyBatteryWarning("Critical")
        elseif batteryPercent < CONFIG.widgets.battery.warning.low then
            notifyBatteryWarning("Low")
        end
    end
    return retval
end

local function construct(_, config)
    local self = textbox()
    setmetatable(self, M)

    self:init(config)

    return self
end

function M:init(config)
    -- TODO: clean up a bunch of this...

    -- register vicious
    if battery.hasBattery() then
        vicious.register(self, customWrapper, config.text or '', config.interval, battery.getDevice())
    end
end

return setmetatable(M, {__call = construct})
