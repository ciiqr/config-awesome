local awful = require("awful")
local naughty = require("naughty")
-- Description:
--      Functions & Functionality that should be provided automatically by awesome (IMO)

-- Imports

-- TODO: probs move errors out of here...
-- Errors --
------------
-- Startup (Only if this is the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Errors Occured During Startup!",
        text = awesome.startup_errors
    })
end
-- Runtime
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end -- Prevent Endless Error Loop
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Errors Occurred",
            text = tostring(err)
        })
        in_error = false
    end)
end

-- Functions --
---------------

-- Programs
function run_once(prg)
    awful.spawn.with_shell('~/.scripts/run-once.sh ' .. prg)
end

-- Clients
function minimizeClient(c)
    -- Prevents Windows Being Minimized if they aren't on the task bar
    -- TODO: I should consider allowing minimizing of these clients and simply causing them to show up on the taskbar (but save their skip_taskbar status and when restoring, also restore skip_taskbar to true)
    if not c.skip_taskbar then
        -- Minimize
        c.minimized = true
    end
end
function toggleClient(c)
  if c == client.focus then
    c.minimized = true
  else
    c.minimized = false
    if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
    end
    client.focus = c
  end
end
function moveClientToTagAndFollow(tagNum, c)
    local c = c or client.focus
    if c then
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
            client.focus:move_to_tag(tag)
            -- Show Tag
            tag:view_only()
        end
    end
end
function moveClientToFirstTagAndFollow(c)
    moveClientToTagAndFollow(1, c)
end
function moveClientToLastTagAndFollow(c)
    moveClientToTagAndFollow(-1, c)
end
-- TODO: Maybe think of a clean way to modularize below 2, would be nice to use moveClientToTagAndFollow
function moveClientLeftAndFollow(c)
    local tags = client.focus.screen.tags
    local curidx = awful.screen.focused().selected_tag.index
    local tag
    if curidx == 1 then
        tag = tags[#tags]
    else
        tag = tags[curidx - 1]
    end
    client.focus:move_to_tag(tag)
    --Follow
    tag:view_only()
end
function moveClientRightAndFollow(c)
    local tags = client.focus.screen.tags
    local curidx = awful.screen.focused().selected_tag.index
    local tag
    if curidx == #tags then
        tag = tags[1]
    else
        tag = tags[curidx + 1]
    end
    --Move
    client.focus:move_to_tag(tag)
    --Follow
    tag:view_only()
end
function toggleClientFullscreen(c)
    c.fullscreen = not c.fullscreen
end
function toggleClientTag(tagNum)
    local tag = client.focus.screen.tags[tagNum]
    if client.focus and tag then
        client.focus:toggle_tag(tag)
    end
end

-- Tags
function toggleTag(tagNum)
    local tag = awful.screen.focused().tags[tagNum]
    if tag then
        awful.tag.viewtoggle(tag)
    end
end
function switchToTag(tagNum)
    local tag = awful.screen.focused().tags[tagNum]
    if tag then
        tag:view_only()
    end
end
