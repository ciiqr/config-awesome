local awful = require("awful")
local gears = require("gears")

local volume = gears.object({})
volume.CHANGED = 'changed'

function volume.toggleMute()
    awful.spawn.easy_async_with_shell('~/.scripts/volume.sh toggle-mute', function()
        volume:emit_signal(volume.CHANGED)
    end)
end

function volume.change(direction, percent)
    awful.spawn.easy_async_with_shell('~/.scripts/volume.sh change '..direction..' '..percent..'%', function()
        volume:emit_signal(volume.CHANGED)
    end)
end

function volume.isMuted()
    local muted = trim(execForOutput("~/.scripts/volume.sh is-muted"))
    return muted == 'yes'
end

function volume.getVolume()
    return execForOutput("~/.scripts/volume.sh get")
end

return volume

-- TODO: would be nice if we could treat this like other global signals and do volume.connect_signal instead of below :
-- volume:connect_signal(volume.CHANGED, function()...end)
