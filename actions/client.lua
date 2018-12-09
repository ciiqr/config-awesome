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
    if c.sticky and c.floating and c.skip_taskbar then
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
        local widthRatio = CONFIG.client.pip.width
        local heightRatio = CONFIG.client.pip.height
        local border = 2 * c.border_width
        local width = math.floor(screenRect.width * widthRatio) - border
        local height = math.floor(screenRect.height * heightRatio) - border
        c:geometry({
            x = screenRect.x + (screenRect.width - width),
            y = screenRect.y + (screenRect.height - height),
            width = width,
            height = height
        })
    end
end

function client.toggleMinimized(c)
  if c == capi.client.focus then
    c.minimized = true
  else
    c.minimized = false
    if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
    end
    capi.client.focus = c
  end
end

function client.debug(c)
    debugPrint("name: " .. (c.name or "null"))
    debugPrint("class: " .. (c.class or "null"))
    debugPrint("role: " .. (c.role or "null"))
    debugPrint("type: " .. (c.type or "null"))
    if c.transient_for then
        name = c.transient_for.name or "null"
        debugPrint("transient for:")
        debugPrint(name)
    end
end

function client.focus(c)
    capi.client.focus = c
    c:raise()
end

return client
