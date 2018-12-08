local awful = require("awful")

local rules = {}

function rules.init()
    awful.rules.rules = require("rules.rules")
end

return rules
