local vicious = require("vicious")
local graph = require("wibox.widget.graph")
local mousebindings = require("mousebindings")

local M = {}; M.__index = M

local function construct(_, config, vertical)
    local self = graph()
    setmetatable(self, M)

    self:init(config, vertical)

    return self
end

function M:init(config, vertical)
    -- TODO: think about this...
    if not vertical then
        self:set_width(50)
    end

    -- TODO: move these to config/theme
    self:set_background_color("#494B4F00") --55
    self:set_color({ type = "linear", from = { 25, 0 }, to = { 25,22 }, stops = { {0, "#FF0000" }, {0.5, "#de5705"}, {1, "#00ff00"} }  })

    -- register vicious
    vicious.register(self, vicious.widgets.cpu, "$1")

    -- buttons
    local buttons = mousebindings.widget(config.mousebindings)
    self:buttons(buttons)

end

return setmetatable(M, {__call = construct})
