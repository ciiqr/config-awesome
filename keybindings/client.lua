local gears = require("gears")
local binding = require("utils.binding")

local environment = {
    client = require("actions.client"),
}
-- Client Key Bindings
local keys = binding.createKeys(CONFIG.client.keybindings, environment)
return gears.table.join(unpack(keys))
