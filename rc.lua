-- Include --
-------------
-- Standard
gears       = require("gears")
awful       = require("awful")
awful.rules = require("awful.rules")
              require("awful.autofocus")
              require("awful.remote")
wibox       = require("wibox")
beautiful   = require("beautiful")
naughty     = require("naughty")
-- Config
inspect     = require("third-party.inspect")
divider     = require("widgets.divider")
thrizen     = require("layouts.thrizen")
xrandr      = require("utils.xrandr")
              require("utils.lua")
              require("utils.awesome")
              require("utils.config")
              require("enums")
CONFIG = require("config")
THEME_PATH = gears.filesystem.get_configuration_dir() .. "/theme"

-- Beautiful Theme
beautiful.init(THEME_PATH .. "/theme.lua")

-- Variables --
---------------
--Model
layouts=nil -- Global, Required
local globalKeys -- Setup
local clientKeys -- Setup
local clientButtons -- Setup
--Visual
tWibox={} -- Persistent
bWibox={} -- Persistent
allWindowsWibox={} -- Persistent
sysInfoWibox={} -- Persistent
local name_callback = {}  -- Persistent
--Widgets
widget_manager = require("widgets.manager")

-- Setup --
-----------
--Layouts
layouts = {
    thrizen,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
}

--Signals

--Client
client.connect_signal("manage", manageClient)
-- Change Border Colours
-- Raise on focus
client.connect_signal("focus", clientDidFocus)
client.connect_signal("unfocus", clientDidLoseFocus)
-- Floating always means ontop
client.connect_signal("property::floating", clientDidChangeFloating)
-- Mouse Over Focus
client.connect_signal("mouse::enter", clientDidMouseEnter)

--Screen
screen.connect_signal("property::geometry", screenSetWallpaper)


-- Per-Screen Setup (Wallpapers, Tags, Pop-down Terminal/Htop/Note, Maximized Layouts, Top/BottomBars)
awful.screen.connect_for_each_screen(function(s)

    local top_layout    = wibox.layout.align.horizontal()
    local left_layout   = wibox.layout.fixed.horizontal()
    local middle_layout = wibox.layout.flex.horizontal()
    local right_layout  = wibox.layout.fixed.horizontal()
    local bottomLayout  = wibox.layout.align.horizontal()
    local allWindowsLayout  = wibox.layout.flex.vertical()
    local sysInfoLayout = wibox.layout.fixed.vertical()

    -- This makes the middle widget centre on on the screen (instead of in the free space)
    top_layout:set_expand("none")

    local SPACING = require("widgets.spacer"):init(beautiful.spacer_size)
    -- local DIVIDER_VERTICAL = divider({size=2, total_size=10, orientation="vertical", end_padding=40}) -- 40 is somewhat arbitrary since the widget will just fill the available height
    local DIVIDER_HORIZONTAL = divider({total_size=0.5, orientation="horizontal", end_padding=40}) -- 40 is somewhat arbitrary since the widget will just fill the available width


    local panel_height = beautiful.panel.height(s)

    -- Wallpaper
    screenSetWallpaper(s)

    --Tags
    awful.tag(CONFIG.screens.tags, s, layouts[1])
    -- - Columns
    for _,tag in pairs(s.tags) do
        awful.tag.setncol(3, tag)
        awful.tag.setmwfact(1/3, tag)
    end

    -- Popup Terminal/Process Info/Notes/etc
    widget_manager:initPopups(s)

    --Wiboxes w/ Widgets
    --Left Widgets
    -- Tag List
    left_layout:add(widget_manager:getTagsList(s))

    --Middle Widget
    -- middle_layout:add(widget_manager:getIP())
    middle_layout:add(widget_manager:getClock())

    --Right Widgets
    -- TODO: hmm
    if s.index == screen.count() then -- Main Widgets on Far Right
        local right_widgets = {
            widget_manager:getNetUsage(),
            widget_manager:getBatteryWidget(),
            widget_manager:getTemperature(),
            widget_manager:getVolume(),
            widget_manager:getMemory(),
            widget_manager:getCPU(),
            widget_manager:getSystemTray(),
            -- widget_manager:getClock()
        }

        for _,widget in pairs(right_widgets) do
            right_layout:add(widget)
            right_layout:add(SPACING)
        end
    end

    -- Layout Box
    right_layout:add(widget_manager:getLayoutBox(s))

    --Add Layouts to Master Layout & Set tWibox Widget to Master Layout
    top_layout:set_left(left_layout)
    top_layout:set_middle(middle_layout)
    top_layout:set_right(right_layout)

    --tWibox
    tWibox[s] = awful.wibox({position = "top", screen = s, height = panel_height})
    tWibox[s]:set_widget(top_layout)
    tWibox[s]:buttons(awful.util.table.join(
        -- awful.button({}, MOUSE_LEFT, function() client.focus = nil; end)
        -- ,awful.button({}, MOUSE_RIGHT, function() goToLayout(-1) end)
    ))

    -- Task List
    bottomLayout:set_middle(widget_manager:getTaskBox(s))
    --bWibox
    bWibox[s] = awful.wibox({position = "bottom", screen = s, height = panel_height})
    bWibox[s]:set_widget(bottomLayout)

    -- All Windows Wibox
    allWindowsLayout:add(widget_manager:getTaskBox(s, true))
    allWindowsWibox[s] = widget_manager:getAllWindowsWibox(s, allWindowsLayout)

    -- System Info wibox
    -- http://stackoverflow.com/questions/8049764/how-can-i-draw-text-with-different-stroke-and-fill-colors-on-images-with-python
    local alignSysInfoLayout = wibox.layout.align.horizontal()
    local fixedSysInfoLayout = wibox.layout.fixed.horizontal()

    sysInfoLayout:add(SPACING)

    function sysInfoLabel(text)
        local label = wibox.widget.textbox(text)
        label:set_align("center")
        return label
    end
    local sysInfoWidgets = {
        -- widget_manager:getSystemTray(true),
        -- sysInfoLabel("Network"), -- SYS-INFO-TITLES
        -- DIVIDER_HORIZONTAL, -- SYS-INFO-TITLES

        widget_manager:getIP(),
        -- widget_manager:getNetUsage(true),

        -- SPACING, -- SYS-INFO-TITLES
        -- sysInfoLabel("Temperature"), -- SYS-INFO-TITLES
        -- DIVIDER_HORIZONTAL, -- SYS-INFO-TITLES

        -- widget_manager:getTemperature(),

        -- SPACING, -- SYS-INFO-TITLES
        -- sysInfoLabel("System"), -- SYS-INFO-TITLES
        -- DIVIDER_HORIZONTAL, -- SYS-INFO-TITLES

        -- widget_manager:getMemory(true),
        -- widget_manager:getCPU(true),
    }

    for _,widget in pairs(sysInfoWidgets) do
        sysInfoLayout:add(widget)
        sysInfoLayout:add(SPACING)
    end

    fixedSysInfoLayout:add(sysInfoLayout)
    fixedSysInfoLayout:add(SPACING)
    alignSysInfoLayout:set_right(fixedSysInfoLayout)

    sysInfoWibox[s] = widget_manager:getSysInfoWibox(s, alignSysInfoLayout)
end)

--Global Key Bindings
globalKeys = awful.util.table.join(
    --Switch Between Tags
    awful.key({SUPER}, "Escape", awful.tag.history.restore),
    awful.key({ALT, CONTROL}, "Left", awful.tag.viewprev),
    awful.key({ALT, CONTROL}, "Right", awful.tag.viewnext),
    awful.key({ALT, CONTROL}, "Up", switchToFirstTag),
    awful.key({ALT, CONTROL}, "Down", switchToLastTag),

    --Toggle Bars
    awful.key({SUPER}, "[", function() toggleWibox(tWibox); toggleWibox(bWibox) end),
    awful.key({SUPER}, "]", function() toggleWibox(bWibox) end),
    awful.key({SUPER}, "c", toggleInfoWiboxes),

    --Modify Layout (NOTE: never use)
    -- awful.key({SUPER, SHIFT}, "h", function() awful.tag.incnmaster(FORWARDS) end),
    -- awful.key({SUPER, SHIFT}, "l", function() awful.tag.incnmaster(BACKWARDS) end),

    --Switch Layout
    awful.key({SUPER}, "space", function() goToLayout(FORWARDS) end),
    awful.key({SUPER, SHIFT}, "space", function() goToLayout(BACKWARDS) end),

    --Swtich Window
    awful.key({SUPER}, "Tab", function() switchClient(FORWARDS) end),
    awful.key({SUPER, SHIFT}, "Tab", function() switchClient(BACKWARDS) end),
    -- Alternatively With Page Up/Down
    awful.key({SUPER}, "Next", function() switchClient(FORWARDS) end),
    awful.key({SUPER}, "Prior", function() switchClient(BACKWARDS) end),

    --ClientRestore
    awful.key({SUPER, CONTROL}, "Up", restoreClient),

    --Maximize
    awful.key({SUPER}, "Up", switchToMaximizedLayout),
    --Revert Maximize
    awful.key({SUPER}, "Down", revertFromMaximizedLayout),

    --Sleep
    awful.key({}, "XF86Sleep", function() awful.util.spawn_with_shell(CONFIG.commands.sleep) end),
    awful.key({SUPER, CONTROL}, "q", function() awful.util.spawn_with_shell(CONFIG.commands.sleep) end),

    -- Add Tag
    awful.key({SUPER}, "y", function()
        -- Add Tag
        newTag = awful.tag.add("Tag "..(#mouse.screen.tags) + 1, {
            layout = thrizen,
        })
        -- Switch to it
        newTag:view_only()
    end),

    -- Remove Tags
    awful.key({SUPER, SHIFT}, "y", function()
        local selectedTags = awful.tag.selectedlist(mouse.screen.index)
        for tag, _ in pairs(selectedTags) do
            awful.tag.delete(_, tag)
        end
    end),

    --Change Position
    awful.key({SUPER}, "Left", function() awful.client.swap.byidx(BACKWARDS) end),
    awful.key({SUPER}, "Right", function() awful.client.swap.byidx(FORWARDS) end),

    --Move Middle
    awful.key({SUPER, SHIFT}, "Left", function() increaseMwfact(-0.05) end),
    awful.key({SUPER, SHIFT}, "Right", function() increaseMwfact(0.05) end),
    -- awful.key({SUPER, SHIFT}, "Up", function() increaseClientWfact(-0.05, client.focus) end), -- TODO: To shift window up/down in size
    -- awful.key({SUPER, SHIFT}, "Down", function() increaseClientWfact(0.05, client.focus) end), -- TODO: To shift window up/down in size

    --Change Number of Columns(Only on splitup side)
    awful.key({SUPER, CONTROL}, "h", function() awful.tag.incncol(FORWARDS) end),
    awful.key({SUPER, CONTROL}, "l", function() awful.tag.incncol(BACKWARDS) end),

    -- Switch beteen screens
    -- TODO: Make it depend on the number of attached screens
        -- Could just have a function that loops through the screen count & calls this the given number of times with the different numbers & joins them to a list
    -- perScreen(function(s)
    --  return awful.key({SUPER}, "F"..s, function() notify_send(s) end)
    -- end),
    awful.key({SUPER}, "F1", function() awful.screen.focus(1) end),
    awful.key({SUPER}, "F2", function() awful.screen.focus(2) end),
    awful.key({SUPER}, "F3", function() awful.screen.focus(3) end),

    --Popups
    -- Launcher Style
    awful.key({SUPER}, "w", function() awful.util.spawn_with_shell(insertScreenWorkingAreaYIntoFormat(CONFIG.commands.fileOpener)) end),
    awful.key({SUPER}, "s", function() awful.util.spawn_with_shell(insertScreenWorkingAreaYIntoFormat(CONFIG.commands.windowSwitcher)) end),

    --Programs
    awful.key({SUPER}, "t", function() awful.util.spawn(CONFIG.commands.terminal) end),

    awful.key({SUPER}, "Return", function() awful.util.spawn(CONFIG.commands.fileManager) end),
    awful.key({SUPER, SHIFT}, "Return", function() awful.util.spawn(CONFIG.commands.graphicalSudo.." "..CONFIG.commands.fileManager) end),

    awful.key({SUPER}, "o", function() awful.util.spawn_with_shell(CONFIG.commands.editor) end),
    awful.key({SUPER, SHIFT}, "o", function() awful.util.spawn_with_shell(CONFIG.commands.graphicalSudo.." "..CONFIG.commands.editor) end),

    --Awesome
    awful.key({SUPER, CONTROL}, "r", awesome.restart),

    --System
    -- Volume
    awful.key({}, "XF86AudioMute", function() widget_manager:toggleMute() end),
    awful.key({}, "XF86AudioLowerVolume", function() widget_manager:changeVolume("-", CONFIG.volume.change.normal) end),
    awful.key({}, "XF86AudioRaiseVolume", function() widget_manager:changeVolume("+", CONFIG.volume.change.normal) end),
    awful.key({SHIFT}, "XF86AudioLowerVolume", function() widget_manager:changeVolume("-", CONFIG.volume.change.small) end),
    awful.key({SHIFT}, "XF86AudioRaiseVolume", function() widget_manager:changeVolume("+", CONFIG.volume.change.small) end),

    -- Brightness
    -- TODO: only setup keybindings if brightness can be adjusted...
    awful.key({}, "XF86MonBrightnessUp", function() changeBrightness("+", CONFIG.brightness.change.normal) end),
    awful.key({}, "XF86MonBrightnessDown", function() changeBrightness("-", CONFIG.brightness.change.normal) end),
    awful.key({SHIFT}, "XF86MonBrightnessUp", function() changeBrightness("+", CONFIG.brightness.change.small) end),
    awful.key({SHIFT}, "XF86MonBrightnessDown", function() changeBrightness("-", CONFIG.brightness.change.small) end),

    -- Invert Screen
    awful.key({SUPER}, "i", function() awful.util.spawn_with_shell(CONFIG.commands.screenInvert) end),

    -- Print Screen
    awful.key({}, "Print", captureScreenshot),

    -- Print Screen (Select Area)
    awful.key({SUPER}, "Print", captureScreenSnip),

    -- Cycle Displays
    awful.key({SUPER}, "F11", xrandr),

    -- Pasteboard paste
    awful.key({}, "Insert", function() awful.util.spawn("xdotool click 2") end), -- put 'keycode 118 = ' back in .Xmodmap if I no longer use this
    awful.key({SUPER}, "Insert", pasteClipboardIntoPrimary) -- TODO: Figure out why it doesn't work

    -- -- Run or raise applications with dmenu
    -- TODO: Client itteration code may be useful, but otherwise I could probably implement this with QuickLaunch
    -- ,awful.key({SUPER, CONTROL}, "p", function()
    --  local f_reader = io.popen( "dmenu_run | dmenu -b -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'")
    --  local command = assert(f_reader:read('*a'))
    --  f_reader:close()
    --  if command == "" then return end

    --  -- Check throught the clients if the class match the command
    --  local lower_command=string.lower(command)
    --  for k, c in pairs(client.get()) do
    --      local class=string.lower(c.class)
    --      if string.match(class, lower_command) then
    --          for i, v in ipairs(c:tags()) do
    --              awful.tag.viewonly(v)
    --              c.minimized = false
    --              return
    --          end
    --      end
    --  end
    --  awful.util.spawn(command)
    -- end)
)
--Tag Keys
-- Uses keycodes to make it works on any keyboard layout
local numberOfTags = #mouse.screen.tags
for i = 1, numberOfTags do
    local iKey = "#"..(i + 9)
    globalKeys = awful.util.table.join(globalKeys,
        awful.key({ALT, CONTROL},       iKey, function() switchToTag(i) end),
        awful.key({SUPER, ALT},         iKey, function() moveClientToTagAndFollow(i) end),

        -- NOTE: Never Used
        awful.key({SUPER, SHIFT},       iKey, function() toggleTag(i) end),
        awful.key({SUPER, CONTROL, ALT},iKey, function() toggleClientTag(i) end)) -- TODO: Change to Control, Alt Shift to be more like mod shift for toggling a tag visibility
end
-- Popup keys
for _,popup in ipairs(CONFIG.popups) do
    globalKeys = awful.util.table.join(globalKeys,
        awful.key({SUPER, SHIFT}, popup.key, function() widget_manager:togglePopup(popup.name) end)
    )
end

--Set Global Keys
root.keys(globalKeys) -- root.keys(musicwidget:append_global_keys(globalKeys))

--Client
--Keys
clientkeys = awful.util.table.join(
    -- Move Between Tags
     awful.key({SUPER, ALT}, "Left", moveClientLeftAndFollow)
    ,awful.key({SUPER, ALT}, "Right", moveClientRightAndFollow)
    ,awful.key({SUPER, ALT}, "Up", moveClientToFirstTagAndFollow)
    ,awful.key({SUPER, ALT}, "Down", moveClientToLastTagAndFollow)
    --Kill
    ,awful.key({SUPER}, "q", function(c) c:kill() end)

    --Fullscreen
    ,awful.key({SUPER}, "f", toggleClientFullscreen)

    -- Multi Fullscreen
    ,awful.key({SUPER, SHIFT}, "f", toggleClientMultiFullscreen)

    --Minimize
    ,awful.key({SUPER, CONTROL}, "Down", minimizeClient)

    --Floating
    ,awful.key({SUPER, ALT}, "space", awful.client.floating.toggle)

    -- Sticky
    ,awful.key({SUPER, ALT}, "s", function(c) c.sticky = not c.sticky end)

    -- PIP
    -- TODO: Move this
    ,awful.key({SUPER, ALT}, "p", function(c)
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
            local screenRect = mouse.screen.geometry
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
    end)

    --Debug Info
    ,awful.key({SUPER}, "g", ternary(DEBUG, debugClient, function()end))
)
--Buttons
clientButtons = awful.util.table.join(
    awful.button({}, MOUSE_LEFT, function(c) client.focus = c; c:raise() end)-- Click Focuses & Raises
    ,awful.button({SUPER}, MOUSE_LEFT, awful.mouse.client.move)              -- Super + Left Moves
    -- ,awful.button({}, MOUSE_MIDDLE, awful.mouse.client.move)              -- Middle Moves -- TODO: I can't currently use this because it conflicts with 'Insert' paste... (if I can convince Insert to be been as shift+Insert then maybe I can enable this...)
    ,awful.button({SUPER}, MOUSE_RIGHT, awful.mouse.client.resize)               -- Super + Right Resizes
    ,awful.button({CONTROL}, MOUSE_SCROLL_UP, function()end) -- Prevent ctrl-scroll zoom
    ,awful.button({CONTROL}, MOUSE_SCROLL_DOWN, function()end) -- Prevent ctrl-scroll zoom
)

--Rules
-- TODO: Use the rules.lua file
-- NOTE: class in the normal rule table can be an array as well, which presumable means it must have all specified classes
awful.rules.rules = {
    {
        rule = {},
        properties = {
            -- Border
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            -- Focus
            focus = awful.client.focus.filter, -- TODO: This is probably the reason that a tingle window isn't focused when we reload, FIX ME
            -- Interaction
            keys = clientkeys,
            buttons = clientButtons,
            -- Prevent Clients Maximized on Start
            maximized_vertical   = false,
            maximized_horizontal = false,
            -- Perfect, I never have to worry about this crap again!
            size_hints_honor = false,
            -- awesome docs suggests these...
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }
    ,{ -- Floating
        rule_any = {
            class = {"speedcrunch", "pinentry", "MPlayer", "Plugin-container", "Exe", "Gtimer", "Vmware-modconfig", "freerdp", "Seafile-applet", "Pavucontrol", "mainframe", "Fuzzy-windows"},
            name = {"Tab Organizer", "Firefox Preferences", "xev-is-special"},
            type = {"dialog", "menu"},
            role = {"toolbox_window"} -- , "pop-up" TODO: Decide if I really like pop-up, cause honestly a lot of things are pop-up's & it's rather annoying ("pop-up")
        },
        properties = {
            floating = true
        }
    }
    -- ,{ -- Ignore Size Hints
    --  rule_any = {
    --      name = {"MonoDevelop", "7zFM", "Vmware", "FrostWire"},
    --      class = {"XTerm", "Ghb", "Skype", "Google-chrome-stable", "Chromium", "Subl3", "Sublime_text", "SmartSVN", "SmartGit"}
    --  },
    --  properties = {
    --      size_hints_honor = false -- TODO: Consider this for the default rule set, probably won't like, but worth a try anyways
    --  }
    -- }
    ,{ -- Popover dialogs will not receive borders
        rule = {
            type = "dialog",
            skip_taskbar = true
        },
        properties = {
            border_width = 0
        }
    }
    ,{
        rule_any = {
            class = {"URxvt"}
        },
        properties = {
            opacity = 0.8
        }
    }
    ,{
        rule = {
            class = "XTerm"
        },
        properties = {
            opacity = 0.8
        }
    }
    ,{
        rule = {
            class = "XTerm",
            name = "MonoDevelop External Console"
        },
        properties = {
            floating = true,
            callback = function(c)
                -- Get screen dimensions
                local workingArea = mouse.screen.workarea
                -- Set window dimensions and position based on screen size...
                local newWidth = workingArea.width / 2
                c:geometry({
                    x = workingArea.width - newWidth,
                    y = workingArea.y,
                    width = newWidth,
                    height = (workingArea.height / 4 * 3)
                })
            end
        }
    }
    ,{
        rule = {
            class = "MonoDevelop",
            skip_taskbar = true
        },
        properties = {
            border_width = 0
        }
    }
    ,{
        rule = {
            class = "albert"
        },
        properties = {
            border_width = 0,
            skip_taskbar = true
        }
    }
    ,{
        rule = {
            class = "Spacefm",
            name = "Choose An Application"
        },
        properties = {
            callback = function(c) c:geometry({width = 500, height = 600}) end
        },
    }
    ,{
        rule = {
            class = "Chromium",
            name = "Authy"
        },
        properties = {
            floating = true
        }
    }
    -- TODO: it seems like the bug that made all this dumb callback stuff necessary has been fixed, clean this up
    ,{
        rule = {
            class = "Google-chrome-stable",
            name = "Untitled" -- All Extension Windows
        },
        properties = {
            callback = function(c)
                -- Function to recheck name
                name_callback[c] = function(c)
                    if c.name then
                        -- Check what the new name is
                        if string.find(c.name, "Tab Organizer") then -- Properties
                            -- Set Floating
                            awful.client.floating.set(c, true)
                            -- Set Ontop
                            -- Change Size
                            local screenDimens = mouse.screen.workarea
                            local screenHeight = screenDimens.height
                            c:geometry({width = screenDimens.width - (2 * beautiful.border_width), height = screenHeight / 2, y = screenHeight/  4, x=0})


                        elseif string.find(c.name, "Select the email service you use") then -- Properties
                            -- Set Floating
                            awful.client.floating.set(c, true)
                        elseif string.find(c.name, "Hangouts") then -- Properties
                            -- NOT Floating
                            awful.client.floating.set(c, false)
                            -- On Social Tag
                            local tags = c.screen.tags
                            awful.client.movetotag(tags[6], c); -- TODO: Add constant for Social Tag Index...
                        else
                            -- Print Name So I Can Possibly Change Other Names
                            -- notify_send(tostring(c.name or "nil"), 2)
                        end
                        -- Clear Client From Callback Array
                        c:disconnect_signal("property::name", name_callback[c])
                        name_callback[c] = nil
                    end
                end
                -- Connect Function
                c:connect_signal("property::name", name_callback[c])
            end
        },
    }
    ,{
        rule = {
            type = "dialog"
        },
        except_any = {
            name = {
                "O", "S", "E"
            }
        },
        properties = {
            callback = function(c)
                -- NOTE: except_any didn't seem to actually be behaving as I expected and was matching on a leafpad window, so we're doing the class check here instead
                if table.indexOf({"Subl3", "Sublime_text"}, c.class) == nil then
                    return
                end

                -- TODO: Fix this up...
                local geom = c:geometry()
                if geom.width == 960 or geom.width == 451 or geom.width == 490 then
                    c:kill();
                end
                notify_send("Sublime\nHis name was Robert.. Oh I Mean '".. (c.name or "nil") .."'", 3);
            end
        }
    }
    ,{
        rule_any = {
            class = {"Subl3", "Sublime_text"},
        },
        except_any = {
            type = {
                "dialog"
            }
        },
        properties = {
            switchtotag = true
            ,callback = function(c)
                local clientName = c.name
                if clientName then

                    -- Find the name in the client's name
                    local find_window = function(name)
                        return clientName:find("%("..name.."%)");
                    end

                    -- Get Tags
                    for name,tag in pairs(CONFIG.clients.sublime.rules) do
                    local tags = c.screen.tags
                    -- Move to Tag
                        if find_window(name) then
                            awful.client.movetotag(tags[tag], c); -- TODO: If I wanted to support having clients on multiple tags, would need to change this and other stuff here...
                            break
                        end
                    end
                end
            end
        }

    }
    ,{
        rule = {
            class = "Seafile-applet",
            type = "normal"
        },
        properties = {
            border_width = 0,
            callback = function(c)
                local screenDimens = mouse.screen.workarea
                local width = 322 -- TODO: Should probably get the actual size OR the actual minimum
                local height = 883
                c:geometry({
                    x = screenDimens.width - width,
                    y = screenDimens.y,
                    width = width,
                    height = height
                })
            end
        }
    }
    ,{
        rule = {
            class = "Seafile-applet",
            type = "dialog"
        },
        properties = {
            callback = function(c)
                local screenDimens = mouse.screen.workarea
                local clientDimens = c:geometry()
                c:geometry({
                    x = (screenDimens.width - clientDimens.width) / 2,
                    y = (screenDimens.height - clientDimens.height) / 2
                })
            end
        }
    }
    ,{
        rule = {
            class = "Pavucontrol"
        },
        properties = {
            callback = function(c)
                local existingDimens = c:geometry()
                screenDimens = mouse.screen.workarea
                local width = existingDimens.width
                local height = existingDimens.height
                c:geometry({
                    x = screenDimens.width - width,
                    y = screenDimens.y,
                    width = width,
                    height = height
                })
            end
        }
    }
    ,{
        rule = {
            class = "Fuzzy-windows"
        },
        properties = {
            callback = function(c)
                local screenDimens = mouse.screen.workarea
                local clientDimens = c:geometry()
                c:geometry({
                    x = (screenDimens.width - clientDimens.width) / 2,
                    y = (screenDimens.height - clientDimens.height) / 2,
                    width = 700, height = 235
                })
            end --
        },
    }
    ,{
        rule = {
            name = "PlayOnLinux Warning"
        },
        properties = {
            callback = function(c) c:kill() end
        }
    }
    ,{
        rule_any = {
            class = {"Skype", "yakyak"},
        },
        properties = {
            tag = mouse.screen.tags[6]
            -- callback = function(c)
            --  -- Floating Windows have a north west gravity, others have static
            --  -- False Assumption
            --  -- if c.size_hints.win_gravity == "north_west" then
            --  --  awful.client.floating.set(c, true)
            --  -- end
            -- end
        }
    }
    ,{
        rule = {
            class = "Nautilus",
            name = "File Operations"
        },
        properties = {
            ontop = true
        }
    }
    ,{
        rule = {
            class = "Plugin-container"
        },
        properties = {
            callback=function(c) c.fullscreen = true end
        }
    }
    ,{
        rule_any = {
            class = {"Vmware"},
            instance = {"TeamViewer.exe"}
        },
        properties = {
            tag = mouse.screen.tags[5]
        }
    }
    ,{
        rule = {
            instance = "TeamViewer.exe",
            name = "Computers & Contacts"
        },
        properties = {
            floating = true
        }
    }
    ,{
        rule = {
            role = "GtkFileChooserDialog"
        },
        properties = {
            callback=  function(c)
                -- Change Size of Normal Window Only
                -- if c.type == "floating" then
                    -- existingDimens = c:geometry()
                    screenDimens = mouse.screen.workarea
                    local height = screenDimens.height * 0.75
                    c:geometry({
                        y = (screenDimens.height - height) / 2,
                        width = screenDimens.width * 0.5,
                        height = height
                    })
                -- end
            end
        }
    }
    -- ,{
    --  rule = {
    --      class = "Vlc"
    --      ,name = "VLCINBACKGROUNDMODE"
    --  },
    --  properties = {
    --      floating = true,
    --      sticky = true,
    --      below = true,
    --      skip_taskbar = true,
    --      border_width = 0,
    --      fullscreen = true,
    --      size_hints = {
    --          user_position = {
    --              x = 0,
    --              y = 0
    --          },
    --          program_position = {
    --              x = 0,
    --              y = 0
    --          },
    --          user_size = {
    --              width = 1920,
    --              height = 1080
    --          },
    --          program_size = {
    --              width = 1920,
    --              height = 1080
    --          }
    --      },
    --      callback = function(c)
    --          c:lower()
    --      end
    --  }
    -- }


    -- TODO: Add a rule so that the toggle-able windows are floating by default
}


-- TODO: Move this, from: http://new.awesomewm.org/apidoc/documentation/90-FAQ.md.html
client.disconnect_signal("request::activate", awful.ewmh.activate)
function awful.ewmh.activate(c)
    if c:isvisible() then
        client.focus = c
        c:raise()
    end
end
client.connect_signal("request::activate", awful.ewmh.activate)

setup_network_connectivity_change_listener()

-- Programs -- (run_once takes a while, probably due to system calls, try making a script that takes a list of files and runs them with the same commands as before)
--------------
for _,program in pairs(CONFIG.startup.programs) do
    run_once(program)
end
