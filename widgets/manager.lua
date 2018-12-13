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
            WidgetManager.getTagsList(s),
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
                    WidgetManager.getNetUsage(),
                    WidgetManager.getBatteryWidget(),
                    Temperature(CONFIG.widgets.temperature),
                    Volume(CONFIG.widgets.volume),
                    Memory(CONFIG.widgets.memory),
                    Cpu(CONFIG.widgets.cpu),
                    wibox.widget.systray(),
                },
            },
            WidgetManager.getLayoutBox(s)
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
        -- WidgetManager.getNetUsage(true),

        -- sysInfoLabel("Temperature"),
        -- Temperature(CONFIG.widgets.temperature),

        -- sysInfoLabel("System"),
        -- WidgetManager.getMemory(),
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

-- TagsList
function WidgetManager.getTagsList(screen)
    -- TODO: not the same as other widget mousebindings, passes in tags
    -- TODO: Consider Moving
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
    -- return awful.widget.taglist(screen, awful.widget.taglist.filter.noempty, buttons)
    return awful.widget.taglist(screen, awful.widget.taglist.filter.all, buttons)
end

-- LayoutBox
function WidgetManager.getLayoutBox(screen)
    local layoutBox = awful.widget.layoutbox(screen)

    local buttons = mousebindings.widget(CONFIG.widgets.layout.mousebindings)
    layoutBox:buttons(buttons)

    return layoutBox
end

-- Net Usage
function WidgetManager.getNetUsage(vertical)
    -- TODO: Make some changes
    local netwidget = wibox.widget.textbox()
    if vertical then
        netwidget:set_align("center")
    end

    local networkDevice = network.getPrimaryDevice()
    local networkTrafficCmd = evalTemplate(CONFIG.commands.networkTraffic, {
        device = networkDevice,
    })

    vicious.register(netwidget, vicious.widgets.net, '<span foreground="#97D599" weight="bold">↑${'..networkDevice..' up_mb}</span> <span foreground="#CE5666" weight="bold">↓${'..networkDevice..' down_mb}</span>', 1) --#585656

    -- TODO: move to config
    netwidget:buttons(gears.table.join(
        awful.button({}, 1, function() awful.spawn(networkTrafficCmd) end)
    ))

    return netwidget
end

-- Battery
function WidgetManager.getBatteryWidget()
    -- TODO: Make so we can update from acpi, ie. DBus acpi notifications
    local widget = wibox.widget.textbox()
    function customWrapper(format, warg)

        local retval = vicious.widgets.bat(format, warg) -- state, percent, time, wear
        local batteryPercent = retval[2]

        if retval[3] == "N/A" then -- Time
            retval[3] = ""
        else
            retval[3] = " "..retval[3]
        end

        -- On Battery
        if retval[1] == "−" then
            local function notifyBatteryWarning(level)
                notifySend(level.." Battery: "..batteryPercent.."% !", 0, naughty.config.presets.critical)
            end
            -- Low Battery
            if batteryPercent < CONFIG.battery.warning.critical then
                notifyBatteryWarning("Critical")
            elseif batteryPercent < CONFIG.battery.warning.low then
                notifyBatteryWarning("Low")
            end
        end
        return retval
    end
    if battery.hasBattery() then
        vicious.register(widget, customWrapper, '<span foreground="#ffcc00" weight="bold">$1$2%$3</span>', 120, battery.getDevice()) --585656
    end

    return widget
end

return WidgetManager
