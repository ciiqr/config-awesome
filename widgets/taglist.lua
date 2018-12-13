local awful = require("awful")
local gears = require("gears")
local taglist = require("awful.widget.taglist")
local client = require("actions.client")

local M = {}; M.__index = M

local function createParentWidget(config, screen)
    -- TODO: not the same as other widget mousebindings, passes in tags
    local SUPER = "Mod4"
    local buttons = gears.table.join(
        awful.button({}, 1, function(t) t:view_only() end), -- Switch to This Tag
        awful.button({SUPER}, 1, function(t) client.focus:move_to_tag(t) end), -- Move Window to This Tag
        awful.button({}, 3, awful.tag.viewtoggle), -- Toggle This Tag
        awful.button({SUPER}, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end)--, -- Toggle This Tag For The current Window
    )

    --TagList
    -- return taglist(screen, taglist.filter.noempty, buttons)
    return taglist(screen, taglist.filter.all, buttons)
end

local function construct(_, config, screen)
    local self = createParentWidget(config, screen)
    setmetatable(self, M)

    return self
end

return setmetatable(M, {__call = construct})
