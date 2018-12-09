require("awful.autofocus")
require("awful.remote")
require("functions")
require("errors")

-- TODO: clean up global (by actually using the config we pass into init)
CONFIG = require("config")

-- init plugins
local plugins = CONFIG.plugins
for i,name in ipairs(plugins) do
    local plugin = require(name)
    plugin.init(CONFIG)
end
