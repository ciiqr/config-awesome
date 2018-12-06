local awful = require("awful")

local command = {}

function command.run(name)
    local cmd = assert(CONFIG.commands[name], "COMMAND_NOT_FOUND: " .. name)
    awful.spawn.with_shell(cmd)
end

return command
