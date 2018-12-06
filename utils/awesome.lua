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
