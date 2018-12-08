local awful = require("awful")

local programs = {}

function programs.init()
    for _,program in ipairs(CONFIG.startup.programs) do
        awful.spawn.with_shell('~/.scripts/run-once.sh ' .. program)
    end
end

return programs
