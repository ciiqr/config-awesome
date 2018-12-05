local beautiful = require("beautiful")
local vicious = require("vicious")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require("gears")
local volume = require("system.volume")
local network = require("system.network")
local battery = require("system.battery")
local popup = require("utils.popup")

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
            WidgetManager.getClock(),
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
                    require("widgets.temperature"):init(),
                    WidgetManager.getVolume(),
                    WidgetManager.getMemory(),
                    WidgetManager.getCPU(),
                    wibox.widget.systray(),
                },
            },
            WidgetManager.getLayoutBox(s)
        },
    }

    -- Bottom Wibar
    s.bottomWibar = awful.wibar({position = "bottom", screen = s, height = panel_height})
    s.bottomWibar:setup {
        widget = WidgetManager.getTaskBox(s),
    }

    -- All Windows Wibox
    s.allWindowsWibox = WidgetManager.getAllWindowsWibox(s)
    s.allWindowsWibox:setup {
        widget = WidgetManager.getTaskBox(s, true),
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
        WidgetManager.getIP(),
        -- WidgetManager.getNetUsage(true),

        -- sysInfoLabel("Temperature"),
        -- require("widgets.temperature"):init(),

        -- sysInfoLabel("System"),
        -- WidgetManager.getMemory(true),
        -- WidgetManager.getCPU(true),
    }
end

-- Volume
function WidgetManager.getVolume()
    local widget = wibox.widget.textbox()

    -- buttons
    widget:buttons(gears.table.join(
        awful.button({}, MOUSE_SCROLL_UP, function() volume.change("+", CONFIG.volume.change.small) end),
        awful.button({}, MOUSE_SCROLL_DOWN, function() volume.change("-", CONFIG.volume.change.small) end),
        awful.button({}, 1, function() run_once("pavucontrol") end)
    ))

    -- TODO: see if we can listen for pulse audio dbus updates

    -- update func
    local function update()
        local displayValue = volume.isMuted() and 'Off' or volume.getVolume()

        -- 🔇 -- Mute icon --
        widget:set_markup('<span foreground="#ffaf5f" weight="bold">🔈 '..displayValue..'</span>')
    end

    -- signal
    volume:connect_signal(volume.CHANGED, update)

    update()
    return widget
end

-- Memory
function WidgetManager.getMemory(vertical)
    local memory = wibox.widget.textbox()
    if vertical then
        memory:set_align("center")
    end
    vicious.register(memory, vicious.widgets.mem, "<span fgcolor='#138dff' weight='bold'>$1% $2MB</span>", 13) --DFDFDF
    memory:buttons(gears.table.join(
        awful.button({}, 1, function() popup.toggle('cpu') end)
    ))
    return memory
end

-- CPU
function WidgetManager.getCPU(vertical)
    local cpuwidget = wibox.widget.graph()
    if not vertical then
        cpuwidget:set_width(50)
    end
    cpuwidget:set_background_color("#494B4F00") --55
    cpuwidget:set_color({ type = "linear", from = { 25, 0 }, to = { 25,22 }, stops = { {0, "#FF0000" }, {0.5, "#de5705"}, {1, "#00ff00"} }  })
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
    cpuwidget:buttons(gears.table.join(
        awful.button({}, 1, function() popup.toggle('mem') end)
    ))
    return cpuwidget
end

-- IP
function WidgetManager.getIP()
    local widget = wibox.widget.textbox()
    widget:set_align("center")

    widget:buttons(gears.table.join(
     awful.button({}, 1, function() awful.spawn(CONFIG.commands.ipInfo) end)
    ))

    -- update func
    local function update()
        local ip = network.getIp()
        widget:set_text(ip)
    end

    -- signal
    dbus.request_name("system", "org.freedesktop.NetworkManager")
    dbus.add_match("system", "interface='org.freedesktop.NetworkManager',member='PropertiesChanged'")
    dbus.connect_signal("org.freedesktop.NetworkManager", function(first, second, ...) -- Doesn't seem to be a third
        update()
    end)

    update()
    return widget
end

-- Text Clock
function WidgetManager.getClock()
    local clock = wibox.widget.textclock(CONFIG.widgets.clock.text, 10)

    -- add popup calendar
    require("widgets.cal").register(clock)

    return clock
end

function WidgetManager.getTaskBox(screen, is_vertical)
    local buttons = gears.table.join(
        awful.button({}, 1, toggleClient)
    )
    if is_vertical then
        local layout = wibox.layout.flex.vertical()

        local common = require("awful.widget.common")
        local function list_update(w, buttons, label, data, objects)
            common.list_update(w, buttons, label, data, objects)
            w:set_max_widget_size(200)
        end

        return awful.widget.tasklist(screen, awful.widget.tasklist.filter.allscreen, buttons, nil, list_update, layout) -- Vertical
    else
        -- TODO: Consider minimizedcurrenttags for filter, it's pretty interesting, though, I would want it to hide if the bottom if there we're no items, or maybe move it back to the top bar & get rid of the bottom entirely...
        return awful.widget.tasklist(screen, awful.widget.tasklist.filter.currenttags, buttons) -- Normal
    end
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
    -- TODO: Consider Moving
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
    local layoutUtils = require("utils.layout")

    local layoutBox = awful.widget.layoutbox(screen)
    layoutBox:buttons(gears.table.join(
        awful.button({}, 1, layoutUtils.viewNext)
        ,awful.button({}, 3, layoutUtils.viewPrev)
    ))

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
    netwidget:buttons(gears.table.join(
        awful.button({}, 1, function() awful.spawn(networkTrafficCmd) end)
    ))

    -- TODO
    -- dbus.connect_signal("org.freedesktop.Notifications", function(signal, value)

        -- notify_send("org.freedesktop.Notifications")
     --    debug_print({signal, value}, 2)
    -- end)

    --dbus.connect_signal("org.freedesktop.Notifications",

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
            local function notify_battery_warning(level)
                notify_send(level.." Battery: "..batteryPercent.."% !", 0, naughty.config.presets.critical)
            end
            -- Low Battery
            if batteryPercent < CONFIG.battery.warning.critical then
                notify_battery_warning("Critical")
            elseif batteryPercent < CONFIG.battery.warning.low then
                notify_battery_warning("Low")
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
