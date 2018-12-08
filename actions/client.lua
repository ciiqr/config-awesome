local awful = require("awful")
local beautiful = require("beautiful")
local capi =
{
    screen = screen,
    client = client,
}

local client = {}

-- global
function client.viewNext()
    awful.client.focus.byidx(FORWARDS)
end

function client.viewPrev()
    awful.client.focus.byidx(BACKWARDS)
end

function client.swapNext()
    awful.client.swap.byidx(FORWARDS)
end

function client.swapPrev()
    awful.client.swap.byidx(BACKWARDS)
end

function client.restore()
    local c = awful.client.restore()
    -- Ensure unminimized client is the new focused client
    if c then
        capi.client.focus = c
    end
end

-- client
function client.moveToTagAndFollow(c, tagNum)
    -- All tags on the screen
    local tags = c.screen.tags
    -- Index of tag
    local index
    if tagNum == -1 then
        index = #tags
    else
        index = tagNum
    end
    -- Get Tag
    local tag = tags[index]
    if tag then
        -- Move Window
        c:move_to_tag(tag)
        -- Show Tag
        tag:view_only()
    end
end

function client.moveLeftAndFollow(c)
    local screen = c.screen
    local current = screen.selected_tag.index
    local tagNum = current == 1 and -1 or current - 1

    client.moveToTagAndFollow(c, tagNum)
end

function client.moveRightAndFollow(c)
    local screen = c.screen
    local current = screen.selected_tag.index
    local tags = screen.tags
    local tagNum = current == #tags and 1 or current + 1

    client.moveToTagAndFollow(c, tagNum)
end

function client.moveToFirstTagAndFollow(c)
    client.moveToTagAndFollow(c, 1)
end

function client.moveToLastTagAndFollow(c)
    client.moveToTagAndFollow(c, -1)
end

function client.toggleTag(c, index)
    local tag = c.screen.tags[index]
    if tag then
        c:toggle_tag(tag)
    end
end

function client.kill(c)
    c:kill()
end

function client.toggleFullscreen(c)
    c.fullscreen = not c.fullscreen
end

-- TODO: Determine if I can make the window adjust when the screen's working area changes, add listener when fullscreen, remove when not
function client.toggleMultiFullscreen(c)
     c.floating = not c.floating
     if c.floating then
         local clientX = capi.screen[1].workarea.x
         local clientY = capi.screen[1].workarea.y
         local clientWidth = 0
         -- look at http://www.rpm.org/api/4.4.2.2/llimits_8h-source.html
         local clientHeight = 2147483640
         for s in capi.screen do
             clientHeight = math.min(clientHeight, s.workarea.height)
             clientWidth = clientWidth + s.workarea.width
         end
         c.border_width = 0
         local t = c:geometry({x = clientX, y = clientY, width = clientWidth, height = clientHeight})
     else
        c.border_width = beautiful.border_width
        -- c.border_color = beautiful.border_focus
        --apply the rules to this client so he can return to the right tag if there is a rule for that.
        awful.rules.apply(c)
     end
     -- focus our client
     capi.client.focus = c
end

function client.minimize(c)
    -- Prevents Windows Being Minimized if they aren't on the task bar
    -- TODO: I should consider allowing minimizing of these clients and simply causing them to show up on the taskbar (but save their skip_taskbar status and when restoring, also restore skip_taskbar to true)
    if not c.skip_taskbar then
        -- Minimize
        c.minimized = true
    end
end

function client.toggleFloating(c)
    c.floating = not c.floating
end

function client.toggleSticky(c)
    c.sticky = not c.sticky
end

function client.togglePip(c)
    -- TODO: Uses sticky to determine if it's in in pip mode or not...
    if c.sticky then
        -- Disable...
        c.sticky = false
        c.skip_taskbar = false
        c.floating = false
    else -- Enable
        c.sticky = true
        c.skip_taskbar = true
        c.floating = true

        -- Get screen dimensions
        local screenRect = awful.screen.focused().geometry
        -- Set window dimensions and position based on screen size...
        local PIP_SIZE_RATIO = 3
        local newWidth = screenRect.width / PIP_SIZE_RATIO
        local newHeight = screenRect.height / PIP_SIZE_RATIO
        c:geometry({
            x = screenRect.x + (screenRect.width - newWidth),
            y = screenRect.y + (screenRect.height - newHeight),
            width = newWidth,
            height = newHeight
        })
    end
end

function client.debug(c)
    -- Window Info
    -- notify_send("size_hints: "..inspect(c.size_hints))

    debug_print("name: " .. (c.name or "null"))
    debug_print("class: " .. (c.class or "null"))
    debug_print("role: " .. (c.role or "null"))
    debug_print("type: " .. (c.type or "null"))
    if c.transient_for then
        name = c.transient_for.name or "null"
        debug_print("transient for: " .. inspect(name))
    end
    -- debug_print("type: " .. inspect(c.type))

    -- Object Info
    -- notify_send("InfoWibox:"..inspect(infoWibox[awful.screen.focused().index], 2))

    -- notify_send("InfoLayout:"..inspect(infoWibox[awful.screen.focused().index].drawin.height, 3))

    -- -- infoLayout:set_max_widget_size(100)
    -- notify_send("InfoLayout:"..inspect(infoLayout, 3))
    -- notify_send("Drawable:"..inspect(infoWibox[awful.screen.focused().index]._drawable, 2))
    -- notify_send("Drawable.Widget:"..inspect(infoWibox[awful.screen.focused().index]._drawable.widget, 2))

    -- Root Object Info
    -- notify_send(inspect(root, 4))
    -- for prop,val in pairs(root) do
    --  notify_send(prop .. inspect(val(), 4))
    -- end

    -- DBus

    -- dbus.connect_signal("org.freedesktop.NetworkManager.Device.Wireless.PropertiesChanged", function (body, bodyMarkup, iconStatic) notify_send("Got DBUS Notification!!!") end)
    -- dbus.request_name("session", "org.freedesktop.NetworkManager.Device.Wireless.PropertiesChanged")

    -- dbus.request_name("system", "org.freedesktop.NetworkManager.Device.Wireless")
    -- dbus.add_match("system", "interface='org.freedesktop.NetworkManager.Device.Wireless',member='PropertiesChanged'")
    -- dbus.connect_signal("org.freedesktop.NetworkManager.Device.Wireless", function(first, property, ...)
    --  ipAddress = property["Ip4Adress"]
    --  if ipAddress then
    --      notify_send(ipAddress)
    --  end
    --  -- notify_send(inspect(first, 3))
    --  -- notify_send(inspect(property, 3))
    -- end)

    -- dbus.request_name("system", "org.freedesktop.DBus.Properties")
    -- dbus.add_match("system", "interface='org.freedesktop.DBus.Properties',member='GetAll',string='org.freedesktop.NetworkManager.Device.Wireless")
    -- dbus.connect_signal("org.freedesktop.DBus.Properties", function(first, property, third, fourth, fifth, ...)
    --  notify_send("There is a Dog!")
    --  -- ipAddress = property["Ip4Adress"]
    --  if ipAddress then
    --      notify_send(ipAddress)
    --  end
    --  -- notify_send(inspect(first, 3))
    --  notify_send(inspect(property, 3))
    --  notify_send(inspect(third, 3))
    --  notify_send(inspect(fourth, 3))
    --  notify_send(inspect(fifth, 3))
    -- end)
    --

    -- Working
    -- dbus.request_name("system", "org.freedesktop.NetworkManager")
    -- dbus.add_match("system", "interface='org.freedesktop.NetworkManager',member='PropertiesChanged'")
    -- dbus.connect_signal("org.freedesktop.NetworkManager", function(first, second, ...) -- Doesn't seem to be a third
    --  -- debug_leaf(first)
    --  -- debug_leaf(second)

    --  if second.Connectivity and second.Connectivity == 4 then
    --      notify_send("DBUS: Connected to WIFI");
    --  elseif second.Connectivity and second.Connectivity == 1 then
    --      notify_send("DBUS: Disconnected from WIFI");
    --  end
    -- end)
end

return client
