local awful = require("awful")

local network = {
    _data = {},
}

function network.getIp()
    local ip = network.getDeviceIp(network.getEthernetDevice())
    if not ip or ip == "" then
        ip = network.getDeviceIp(network.getWifiDevice())
    end

    return ip
end

function network.getDeviceIp(device)
    return execForOutput("ip addr show dev " .. device .. " | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | tr -d '\n'")
end

function network.getPrimaryDevice()
    local ethernet = network.getEthernetDevice()
    local wifi = network.getWifiDevice()

    return ethernet == "" and wifi or ethernet
end

function network.getWifiDevice()
    if not network._data.wifiDevice then
        network._data.wifiDevice = trim(execForOutput("ls /sys/class/net/wl* >/dev/null 2>&1 && basename /sys/class/net/wl*"))
    end

    return network._data.wifiDevice
end

function network.getEthernetDevice()
    if not network._data.ethDevice then
        network._data.ethDevice = trim(execForOutput("ls /sys/class/net/e* >/dev/null 2>&1 && basename /sys/class/net/e*"))
    end

    return network._data.ethDevice
end

return network
