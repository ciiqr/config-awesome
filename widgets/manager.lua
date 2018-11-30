local beautiful = beautiful or require("beautiful")
local vicious = vicious or require("vicious")
local quake = quake or require("quake")

local WidgetManager = {
    -- TODO: should pass this in when I create a new widget manager...
    config = CONFIG.widgets or {},
    quake = {},
}

WidgetManager.wifiDevice = trim(execForOutput("ls /sys/class/net/wl* >/dev/null 2>&1 && basename /sys/class/net/wl*"))
WidgetManager.ethDevice = trim(execForOutput("ls /sys/class/net/e* >/dev/null 2>&1 && basename /sys/class/net/e*"))
WidgetManager.batteryDevice = trim(execForOutput("ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && basename /sys/class/power_supply/BAT*"))

-- Popup Terminal
function WidgetManager:initPopups(s)
    for _,popup in ipairs(CONFIG.popups) do
        -- Ensure we have a table
        if not self.quake[popup.name] then
            self.quake[popup.name] = {}
        end

        -- get options
        local defaults = {
            screen = s,
            border = 0,
        }
        local options = popup.options or {}
        local quakeOptions = awful.util.table.join(defaults, options)

        -- Create Popup
        self.quake[popup.name][s] = quake(quakeOptions)
    end
end
function WidgetManager:togglePopup(name, screen)
    -- Toggle Popup
    self.quake[name][screen or mouse.screen]:toggle()
end

-- Volume
function WidgetManager:getVolume()
    self.volume = wibox.widget.textbox() -- 🔇 -- Mute icon --
    self.volume:buttons(awful.util.table.join(
        awful.button({}, MOUSE_SCROLL_UP, function() WidgetManager:changeVolume("+", CONFIG.volume.change.small) end),
        awful.button({}, MOUSE_SCROLL_DOWN, function() WidgetManager:changeVolume("-", CONFIG.volume.change.small) end),
        awful.button({}, 1, function() run_once("pavucontrol") end)
    ))

    self:displayVolume()
    return self.volume
end
function WidgetManager:changeVolume(incORDec, change)
    -- Change
    awful.spawn.easy_async_with_shell('~/.scripts/volume.sh change '..incORDec..' '..change..'%', function()
        self:displayVolume()
    end)
end
function WidgetManager:toggleMute()
    awful.spawn.easy_async_with_shell('~/.scripts/volume.sh toggle-mute', function()
        self:displayVolume()
    end)
end
function WidgetManager:displayVolume()
    local displayValue = self:getVolumeForDisplay()

    self.volume:set_markup('<span foreground="#ffaf5f" weight="bold">🔈 '..displayValue..'</span>')
end
function WidgetManager:isMuted()
    local muted = trim(execForOutput("~/.scripts/volume.sh is-muted"))
    return muted == 'yes'
end
function WidgetManager:getVolumePercent()
    return execForOutput("~/.scripts/volume.sh get")
end
function WidgetManager:getVolumeForDisplay()
    if self:isMuted() then
        return 'Off'
    end

    return self:getVolumePercent()
end

-- Memory
function WidgetManager:getMemory(vertical)
    self.memory = wibox.widget.textbox()
    if vertical then
        self.memory:set_align("center")
    end
    vicious.register(self.memory, vicious.widgets.mem, "<span fgcolor='#138dff' weight='bold'>$1% $2MB</span>", 13) --DFDFDF
    self.memory:buttons(awful.util.table.join(
        awful.button({}, 1, function() self:togglePopup('cpu') end)
    ))
    return self.memory
end

-- CPU
function WidgetManager:getCPU(vertical)
    local cpuwidget = awful.widget.graph()
    if not vertical then
        cpuwidget:set_width(50)
    end
    cpuwidget:set_background_color("#494B4F00") --55
    cpuwidget:set_color({ type = "linear", from = { 25, 0 }, to = { 25,22 }, stops = { {0, "#FF0000" }, {0.5, "#de5705"}, {1, "#00ff00"} }  })
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
    cpuwidget:buttons(awful.util.table.join(
        awful.button({}, 1, function() self:togglePopup('mem') end)
    ))
    return cpuwidget
end

-- System Tray
function WidgetManager:getSystemTray(vertical)
    self.sysTray = wibox.widget.systray()
    self.sysTray.set_horizontal(not vertical)
    self.sysTray.isSysTray = true
    self.sysTray.orig_fit = self.sysTray.fit
    self.sysTray.fit = function(self, ctx, width, height)
        -- Original
        local width, height = self:orig_fit(ctx, width, height)

        -- Hidden
        if self.hidden then
            return 0, 0
        else-- Visible
            return width, height
        end
    end
    return self.sysTray
end

-- IP
function WidgetManager:getIP()
    self.ip = wibox.widget.textbox()
    self.ip:set_align("center")

    self:updateIP()

    self.ip:buttons(awful.util.table.join(
     awful.button({}, 1, function() awful.util.spawn(CONFIG.commands.ipInfo) end)
     -- ,awful.button({}, 3, function() self.ip:updateIP() end)
    ))
    return self.ip
end

function WidgetManager:updateIP()
    local ip = retrieveIPAddress(self.ethDevice)
    if ip == "" then
        ip = retrieveIPAddress(self.wifiDevice)
    end
    self.ip:set_text(ip)
end

-- Text Clock
function WidgetManager:getClock()
    self.clock = wibox.widget.textclock(self.config.clock.text, 10)

    -- add popup calendar
    require("widgets.cal").register(self.clock)

    return self.clock
end

function WidgetManager:getTaskBox(screen, is_vertical)
    -- TODO: These need to be seperate per screen, therefore I need a list for each, ie. WidgetManager.verticalTaskBoxes, WidgetManager.horizontalTaskBoxes
    local buttons = awful.util.table.join(
        awful.button({}, 1, toggleClient),
        awful.button({}, 3, toggleInfoWiboxes)
    )
    if is_vertical then
        local layout = wibox.layout.flex.vertical()
        local widget = awful.widget.tasklist(screen, awful.widget.tasklist.filter.allscreen, buttons, nil, nil, layout) -- Vertical
        -- layout:fit_widget(widget, 100, 100)
        layout:fit({}, 100, 100)
        widget:fit({}, 100, 100)
        -- widget = awful.widget.layoutbox(screen)
        -- notify_send(inspect(layout, 2))
        -- notify_send(inspect(widget, 2))
        return widget
    else
        -- TODO: Consider minimizedcurrenttags for filter, it's pretty interesting, though, I would want it to hide if the bottom if there we're no items, or maybe move it back to the top bar & get rid of the bottom entirely...
        return awful.widget.tasklist(screen, awful.widget.tasklist.filter.currenttags, buttons) -- Normal
        -- allscreen,  All on Screen, Normal
    end
end

function WidgetManager:getAllWindowsWibox(s, widget)
    -- 'awful.wibox' to have it affect the workarea
    local aWibox = wibox({
        position = "left",
        screen = s,
        width = beautiful.global_windows_list_width,
        ontop = true,
        visible = false})
    aWibox:set_widget(widget)

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

function WidgetManager:getSysInfoWibox(s, widget)
    local width = beautiful.system_info_width
    -- 'awful.wibox' to have it affect the workarea
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

    aWibox:set_widget(widget)

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
function WidgetManager:getTagsList(screen)
    -- TODO: Consider Moving
    local buttons = awful.util.table.join(
        awful.button({}, 1, awful.tag.viewonly), -- Switch to This Tag
        awful.button({SUPER}, 1, awful.client.movetotag), -- Move Window to This Tag
        awful.button({}, 3, awful.tag.viewtoggle), -- Toggle This Tag
        awful.button({SUPER}, 3, awful.client.toggletag)--, -- Toggle This Tag For The current Window
    )

    --TagList
    -- TODO: CHange so it stores the tagsList for all screens
    -- self.tagsList = awful.widget.taglist(screen, awful.widget.taglist.filter.noempty, buttons)
    self.tagsList = awful.widget.taglist(screen, awful.widget.taglist.filter.all, buttons)
    return self.tagsList
end

-- LayoutBox
function WidgetManager:getLayoutBox(screen)
    -- TODO: CHange so it stores the layoutBoxes for all screens
    self.layoutBox = awful.widget.layoutbox(screen)
    self.layoutBox:buttons(awful.util.table.join(
        awful.button({}, 1, function() goToLayout(1) end)
        ,awful.button({}, 3, function() goToLayout(-1) end)
    ))

    return self.layoutBox
end

-- Temperature
function WidgetManager:getTemperature()
    self.temperature = require("widgets.temperature"):init()
    return self.temperature
end

-- Net Usage
function WidgetManager:getNetUsage(vertical)
    -- TODO: Make some changes
    self.netwidget = wibox.widget.textbox()
    if vertical then
        self.netwidget:set_align("center")
    end

    local networkDevice = ternary(self.ethDevice == "", self.wifiDevice, self.ethDevice)
    local networkTrafficCmd = evalTemplate(CONFIG.commands.networkTraffic, {
        device = networkDevice,
    })

    vicious.register(self.netwidget, vicious.widgets.net, '<span foreground="#97D599" weight="bold">↑${'..networkDevice..' up_mb}</span> <span foreground="#CE5666" weight="bold">↓${'..networkDevice..' down_mb}</span>', 1) --#585656
    self.netwidget:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.util.spawn(networkTrafficCmd) end)
    ))

    -- TODO
    -- dbus.connect_signal("org.freedesktop.Notifications", function(signal, value)

        -- notify_send("org.freedesktop.Notifications")
     --    notify_send(inspect({signal, value}, 2))
    -- end)

    --dbus.connect_signal("org.freedesktop.Notifications",

    return self.netwidget
end

-- Battery
function WidgetManager:getBatteryWidget()
    -- TODO: Make so we can update from acpi, ie. DBus acpi notifications
    self.battery = wibox.widget.textbox()
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
    if self.batteryDevice ~= "" then
        vicious.register(self.battery, customWrapper, '<span foreground="#ffcc00" weight="bold">$1$2%$3</span>', 120, self.batteryDevice) --585656
    end

    return self.battery
end

return WidgetManager
