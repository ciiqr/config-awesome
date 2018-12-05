local awful = require("awful")

local battery = {
    _data = {},
}

function battery.hasBattery()
    local device = battery.getDevice()
    return device ~= ""
end

function battery.getDevice()
    if not battery._data.device then
        battery._data.device = trim(execForOutput("ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && basename /sys/class/power_supply/BAT*"))
    end

    return battery._data.device
end

return battery
