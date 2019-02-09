local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local XRandR =
{
    iterator = nil,
    timer    = nil,
    id       = nil,

    display_icon = "/usr/share/icons/gnome/32x32/devices/display.png" -- Default: Tango
}

-- Get active outputs
function XRandR:displayOutputs()
    local displayOutputs = {}
    local xrandr = io.popen("xrandr -q")
    if xrandr then
        for line in xrandr:lines() do
            output = line:match("^([%w-]+) connected ")
            if output then
                displayOutputs[#displayOutputs + 1] = output
            end
        end
        xrandr:close()
    end

    return displayOutputs
end
function XRandR:arrangeDisplays(out)
    -- We need to enumerate all the way to combinate output. We assume
    -- we want only an horizontal layout.
    local choices   = {}
    local previous  = { {} }
    for i = 1, #out do
        -- Find all permutation of length `i`: we take the permutation
        -- of length `i-1` and for each of them, we create new
        -- permutations by adding each output at the end of it if it is
        -- not already present.
        local new = {}
        for _, p in pairs(previous) do
            for _, o in pairs(out) do
                if not gears.table.hasitem(p, o) then
                    new[#new + 1] = gears.table.join(p, {o})
                end
            end
        end
        choices = gears.table.join(choices, new)
        previous = new
    end

    return choices
end
-- Build available choices
function XRandR:displaysMenu()
    local menu = {}
    local out = self:displayOutputs()
    local choices = self:arrangeDisplays(out)

    for _, choice in pairs(choices) do
        local cmd = "xrandr"
        -- Enabled displayOutputs
        for i, o in pairs(choice) do
            cmd = cmd .. " --output " .. o .. " --auto"
            if i > 1 then
                cmd = cmd .. " --right-of " .. choice[i-1]
            end
        end
         -- Disabled outputs
        for _, o in pairs(out) do
            if not gears.table.hasitem(choice, o) then
                cmd = cmd .. " --output " .. o .. " --off"
            end
        end

        local label = ""
        if #choice == 1 then
            label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
        else
            for i, o in pairs(choice) do
            if i > 1 then label = label .. " + " end
                label = label .. '<span weight="bold">' .. o .. '</span>'
            end
        end

        menu[#menu + 1] = {
            label,
            cmd,
            self.display_icon
        }
    end

    return menu
end
function XRandR:cycle()
    -- Stop any previous timer
    if self.timer then
        self.timer:stop()
        self.timer = nil
    end

    -- Build the list of choices
    if not self.iterator then
        self.iterator = gears.table.iterate(self:displaysMenu(), function() return true end)
    end

    -- Select one and display the appropriate notification
    local next = self.iterator()
    local label, action, icon
    if not next then
        label, icon = "Keep the current configuration", self.display_icon
        self.iterator = nil
    else
        label, action, icon = table.unpack(next)
    end
    self.id = naughty.notify({
        text = label,
        icon = icon,
        timeout = 4,
        screen = awful.screen.focused().index, -- Important, not all screens may be visible
        font = "Free Sans 18",
        replaces_id = self.id
    }).id

    -- Setup the timer
    self.timer = gears.timer({timeout = 4})
    self.timer:connect_signal("timeout", function()
        self.timer:stop()
        self.timer = nil
        self.iterator = nil
        if action then
            awful.spawn(action, false)
        end
    end)
    self.timer:start()
end

return function()
    XRandR:cycle()
end
