local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local tasklist = require("awful.widget.tasklist")
local client = require("actions.client")

local M = {}; M.__index = M

local function createParentWidget(config, screen, vertical)
    -- TODO: these aren't the same sort of widget bindings since they pass in the clients
    local buttons = gears.table.join(
        awful.button({}, 1, client.toggleMinimized)
    )
    if vertical then
        local layout = wibox.layout.flex.vertical()

        local common = require("awful.widget.common")
        local function listUpdate(w, buttons, label, data, objects)
            common.list_update(w, buttons, label, data, objects)
            w:set_max_widget_size(200)
        end

        return tasklist(screen, tasklist.filter.allscreen, buttons, nil, listUpdate, layout) -- Vertical
    else
        -- TODO: Consider minimizedcurrenttags for filter, it's pretty interesting, though, I would want it to hide if the bottom if there we're no items, or maybe move it back to the top bar & get rid of the bottom entirely...
        return tasklist(screen, tasklist.filter.currenttags, buttons) -- Normal
    end
end

local function construct(_, config, screen, vertical)
    local self = createParentWidget(config, screen, vertical)
    setmetatable(self, M)

    return self
end

return setmetatable(M, {__call = construct})
