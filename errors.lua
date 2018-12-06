local naughty = require("naughty")

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
