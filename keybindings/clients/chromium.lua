local awful = require("awful")
local gears = require("gears")
local binding = require("utils.binding")

local environment = {
    chromium = {
        quit = function()
            awful.spawn.with_shell('sleep 0.1;xdotool key --clearmodifiers "alt+f";xdotool key --clearmodifiers "x"')
        end
    },
}

-- Client Key Bindings
local keys = binding.createKeys(CONFIG.chromium.keybindings, environment)
local defaultKeys = require("keybindings.client")
return gears.table.join(defaultKeys, gears.table.join(table.unpack(keys)))
