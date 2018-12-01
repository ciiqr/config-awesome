-- Dependencies: xrandr

-- Usage:
--      local xrandr = require("utils.xrandr")
--      awful.key({modkey}, "F11", xrandr)

require("utils.lua")

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
        label, action, icon = unpack(next)
    end
    self.id = naughty.notify({
        text = label,
        icon = icon,
        timeout = 4,
        screen = mouse.screen.index, -- Important, not all screens may be visible
        font = "Free Sans 18",
        replaces_id = self.id
    }).id

    -- Setup the timer
    self.timer = timer { timeout = 4 }
    self.timer:connect_signal("timeout", function()
        self.timer:stop()
        self.timer = nil
        self.iterator = nil
        if action then
            awful.util.spawn(action, false)
        end
    end)
    self.timer:start()
end

return bindFunc(XRandR.cycle, XRandR)

-- -- Get active outputs
-- local function outputs()
--    local outputs = {}
--    local xrandr = io.popen("xrandr -q")
--    if xrandr then
--       for line in xrandr:lines() do
--   output = line:match("^([%w-]+) connected ")
--   if output then
--      outputs[#outputs + 1] = output
--   end
--       end
--       xrandr:close()
--    end

--    return outputs
-- end

-- local function arrange(out)
--    -- We need to enumerate all the way to combinate output. We assume
--    -- we want only an horizontal layout.
--    local choices  = {}
--    local previous = { {} }
--    for i = 1, #out do
--       -- Find all permutation of length `i`: we take the permutation
--       -- of length `i-1` and for each of them, we create new
--       -- permutations by adding each output at the end of it if it is
--       -- not already present.
--       local new = {}
--       for _, p in pairs(previous) do
--   for _, o in pairs(out) do
--      if not gears.table.hasitem(p, o) then
--         new[#new + 1] = gears.table.join(p, {o})
--      end
--   end
--       end
--       choices = gears.table.join(choices, new)
--       previous = new
--    end

--    return choices
-- end

-- -- Build available choices
-- local function menu()
--    local menu = {}
--    local out = outputs()
--    local choices = arrange(out)

--    for _, choice in pairs(choices) do
--       local cmd = "xrandr"
--       -- Enabled outputs
--       for i, o in pairs(choice) do
--   cmd = cmd .. " --output " .. o .. " --auto"
--   if i > 1 then
--      cmd = cmd .. " --right-of " .. choice[i-1]
--   end
--       end
--       -- Disabled outputs
--       for _, o in pairs(out) do
--   if not gears.table.hasitem(choice, o) then
--      cmd = cmd .. " --output " .. o .. " --off"
--   end
--       end

--       local label = ""
--       if #choice == 1 then
--   label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
--       else
--   for i, o in pairs(choice) do
--      if i > 1 then label = label .. " + " end
--      label = label .. '<span weight="bold">' .. o .. '</span>'
--   end
--       end

--       menu[#menu + 1] = { label,
--            cmd,
--                           "/usr/share/icons/Tango/32x32/devices/display.png"}
--    end

--    return menu
-- end

-- -- Display xrandr notifications from choices
-- local state = { iterator = nil,
--      timer = nil,
--      cid = nil }
-- local function xrandr()
--    -- Stop any previous timer
--    if state.timer then
--       state.timer:stop()
--       state.timer = nil
--    end

--    -- Build the list of choices
--    if not state.iterator then
--       state.iterator = gears.table.iterate(menu(),
--                  function() return true end)
--    end

--    -- Select one and display the appropriate notification
--    local next  = state.iterator()
--    local label, action, icon
--    if not next then
--       label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
--       state.iterator = nil
--    else
--       label, action, icon = unpack(next)
--    end
--    state.cid = naughty.notify({ text = label,
--              icon = icon,
--              timeout = 4,
--              screen = mouse.screen.index, -- Important, not all screens may be visible
--              font = "Free Sans 18",
--              replaces_id = state.cid }).id

--    -- Setup the timer
--    state.timer = timer { timeout = 4 }
--    state.timer:connect_signal("timeout",
--            function()
--               state.timer:stop()
--               state.timer = nil
--               state.iterator = nil
--               if action then
--              awful.util.spawn(action, false)
--               end
--            end)
--    state.timer:start()
-- end

-- return xrandr
