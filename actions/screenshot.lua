local awful = require("awful")

local screenshot = {}

function screenshot.capture()
    awful.spawn.easy_async_with_shell(CONFIG.commands.screenshot, function()
        notifySend("Screenshot Taken", 1)
    end)
end

function screenshot.snip()
    awful.spawn.easy_async_with_shell(CONFIG.commands.screenshotSelect, function()
        notifySend("Screenshot Taken", 1)
    end)
end

return screenshot
