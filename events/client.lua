local awful = require("awful")
local beautiful = require("beautiful")

local capi =
{
    awesome = awesome,
    client = client,
}

local client = {}

local function clientShouldAttemptFocus(c)
    -- NOTE: Experimental support for not changing focus from transient back to it's parent
    -- NOTE: If there is another client on screen then we can still switch to that client then back to the parent...
    -- NOTE: ALSO: Experimental support for not changing focus to fullscreen windows automatically, intended to help with the fact that fullscreen windows are displayed over top of wiboxes
    -- NOTE: Also with the fullscreen note above, the or current client floating means that I can quickly switch between a fullscreen window & say my calculator
    -- DEFAULT: and awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    if (not capi.client.focus) or awful.client.focus.filter(c) and ((not capi.client.focus) or capi.client.focus.transient_for ~= c) and (not c.fullscreen or capi.client.focus.floating) then
        capi.client.focus = c
    end
end

local function setupClientRequestActivate()
    -- from: http://new.awesomewm.org/apidoc/documentation/90-FAQ.md.html
    capi.client.disconnect_signal("request::activate", awful.ewmh.activate)
    function awful.ewmh.activate(c)
        if c:isvisible() then
            capi.client.focus = c
            c:raise()
        end
    end
    capi.client.connect_signal("request::activate", awful.ewmh.activate)
end

local function transientShouldBeSticky(c)
    return (c.name and c.name:find("LEAFPAD_QUICK_NOTE")) -- or
end

function client.init()
    capi.client.connect_signal("manage", client.manage)
    capi.client.connect_signal("focus", client.focus)
    capi.client.connect_signal("unfocus", client.unfocus)
    capi.client.connect_signal("property::floating", client.propertyFloating)
    capi.client.connect_signal("mouse::enter", client.mouseEnter)
    setupClientRequestActivate()
end

function client.manage(c)
    -- When first created

    -- TODO: need to confirm this is fine...
    -- if not startup then
    --     -- determines order of new clients
    --     awful.client.setslave(c)
    --     -- Position
    --     if not c.size_hints.user_position and not c.size_hints.program_position then
    --         awful.placement.no_overlap(c)
    --         awful.placement.no_offscreen(c)
    --     end
    -- end
    if not capi.awesome.startup then
        awful.client.setslave(c)
    end

    if capi.awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Subwindows Sticky
    if c.transient_for and transientShouldBeSticky(c) then
        notifySend("Transient's UNITE!")
        c.sticky = true
    end

    -- TODO: 2 below, this is also in property-change/event-handlers & it would be nice if it was only in one location...
    -- If a client is automatically floating, make it ontop
    client.propertyFloating(c)

    if capi.client.focus == c then
        client.focus(c)
    end
end

function client.focus(c)
    c.border_color = beautiful.border_focus
    c:raise()
end

function client.unfocus(c)
    c.border_color = beautiful.border_normal
end

function client.propertyFloating(c)
    c.ontop = c.floating and not c.fullscreen
end

function client.mouseEnter(c)
    if not c.minimized then
        clientShouldAttemptFocus(c)
    end
end

return client
