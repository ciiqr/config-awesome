local beautiful = require("beautiful")
local vicious = require("vicious")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require("gears")
local network = require("system.network")
local battery = require("system.battery")
local popup = require("actions.popup")
local mousebindings = require("mousebindings")
local Volume = require("widgets.volume")
local Temperature = require("widgets.temperature")
local Memory = require("widgets.memory")
local Cpu = require("widgets.cpu")
local Ip = require("widgets.ip")
local Clock = require("widgets.clock")
local Tasklist = require("widgets.tasklist")
local Taglist = require("widgets.taglist")
local Layoutbox = require("widgets.layoutbox")
local Netusage = require("widgets.netusage")
local Battery = require("widgets.battery")

-- TODO: it's been great but I think it's time for us to split

local WidgetManager = {}

-- Wibars/Wiboxes
function WidgetManager.initWiboxes(s)
    local panel_height = beautiful.panel.height(s)

    -- Top Wibar
    s.topWibar = awful.wibar({position = "top", screen = s, height = panel_height})
    s.topWibar:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout = wibox.layout.fixed.horizontal,
            Taglist(CONFIG.widgets.taglist, s),
        },
        {
            layout = wibox.layout.flex.horizontal,
            Clock(CONFIG.widgets.clock),
        },
        {
            layout = wibox.layout.fixed.horizontal,
            {
                layout = awful.widget.only_on_screen,
                screen = "primary",
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = beautiful.spacer_size,
                    Netusage(CONFIG.widgets.netusage),
                    Battery(CONFIG.widgets.battery),
                    Temperature(CONFIG.widgets.temperature),
                    Volume(CONFIG.widgets.volume),
                    Memory(CONFIG.widgets.memory),
                    Cpu(CONFIG.widgets.cpu),
                    wibox.widget.systray(),
                },
            },
            Layoutbox(CONFIG.widgets.layoutbox, s),
        },
    }

    -- Bottom Wibar
    s.bottomWibar = awful.wibar({position = "bottom", screen = s, height = panel_height})
    s.bottomWibar:setup {
        widget = Tasklist(CONFIG.widgets.tasklist, s),
    }

    -- All Windows Wibox
    s.allWindowsWibox = WidgetManager.getAllWindowsWibox(s)
    s.allWindowsWibox:setup {
        widget = Tasklist(CONFIG.widgets.tasklist, s, true),
    }

    -- System Info wibox

    function sysInfoLabel(text)
        local label = wibox.widget.textbox(text)
        label:set_align("center")
        return label
    end

    s.sysInfoWibox = WidgetManager.getSysInfoWibox(s)
    s.sysInfoWibox:setup {
        layout = wibox.layout.fixed.vertical,

        wibox.widget.textbox(' '),

        -- sysInfoLabel("Network"),
        Ip(CONFIG.widgets.ip),
        -- Netusage(CONFIG.widgets.netusage),

        -- sysInfoLabel("Temperature"),
        -- Temperature(CONFIG.widgets.temperature),

        -- sysInfoLabel("System"),
        -- Memory(CONFIG.widgets.memory),
        -- Cpu(CONFIG.widgets.cpu, true),
    }
end

function WidgetManager.getAllWindowsWibox(s)
    local aWibox = wibox({
        position = "left",
        screen = s,
        width = beautiful.global_windows_list_width,
        ontop = true,
        visible = false})

    -- Function to resize the wibox
    local sizeWibox = function(screen)
        -- Adjust the AllWindowsWibox's height when the working area changes
        aWibox.y = screen.workarea.y
        aWibox.height = screen.workarea.height
    end

    -- Set the initial size
    sizeWibox(s)
    -- Resize on working area change
    s:connect_signal("property::workarea", sizeWibox)

    -- TODO: on task list change it should update height, never more than workarea
    return aWibox
end

function WidgetManager.getSysInfoWibox(s)
    local width = beautiful.system_info_width
    local aWibox = wibox({
        position = "right",
        screen = s,
        x = s.workarea.width - width,
        width = width,
        -- bg = "#222222FF",
        -- bg = "22222288",
        -- bg = "linear:0,0:"..width..",0:0,#22222200:0.25,#22222266:0.5,#2222227F:1,#",
        -- bg = { type = "linear", from = {0, 0}, to = {width, 0}, stops = {{0, "#22222200"}, {0.5, "#2222227F"}, {1, "#22222288"}}},
        ontop = true,
        visible = false
    })

    -- Function to resize the wibox
    local sizeWibox = function(screen)
        -- Adjust the AllWindowsWibox's height when the working area changes
        aWibox.y = screen.workarea.y
        aWibox.height = screen.workarea.height
    end

    -- Set the initial size
    sizeWibox(s)
    -- Resize on working area change
    s:connect_signal("property::workarea", sizeWibox)

    return aWibox
end

return WidgetManager
