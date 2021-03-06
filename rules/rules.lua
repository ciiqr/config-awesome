local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local name_callback = {}

-- TODO: improve

-- TODO: v4 introduced custom user rules, should use to help us configify the rules
    -- https://awesomewm.org/apidoc/documentation/89-NEWS.md.html#v4

return {
    { -- Default
        rule = {},
        properties = {
            -- Border
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            -- Focus
            focus = awful.client.focus.filter, -- TODO: This is probably the reason that a tingle window isn't focused when we reload, FIX ME
            -- Interaction
            keys = require("keybindings.client"),
            buttons = require("mousebindings.client"),
            -- Prevent Clients Maximized on Start
            maximized = false,
            maximized_vertical   = false,
            maximized_horizontal = false,
            -- TODO: Prevent Clients preserving their tags on Start, below breaks awesome restart, but idk if there's another reasonable way to do this...
            tags = {""},
            -- Perfect, I never have to worry about this crap again!
            size_hints_honor = false,
            -- awesome docs suggests these...
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        },
    },
    { -- Floating
        rule_any = {
            class = {"speedcrunch", "pinentry", "MPlayer", "Plugin-container", "Exe", "Gtimer", "Vmware-modconfig", "freerdp", "Seafile-applet", "Pavucontrol", "mainframe", "Fuzzy-windows"},
            name = {"Tab Organizer", "Firefox Preferences", "xev-is-special"},
            type = {"dialog", "menu"},
            role = {"toolbox_window"}, -- , "pop-up" TODO: Decide if I really like pop-up, cause honestly a lot of things are pop-up's & it's rather annoying ("pop-up")
        },
        properties = {
            floating = true,
        },
    },
    { -- Popover dialogs will not receive borders
        rule = {
            type = "dialog",
            skip_taskbar = true,
        },
        properties = {
            border_width = 0,
        },
    },
    { -- Terminals transparent
        rule_any = {
            class = {"URxvt", "XTerm", "Alacritty"},
        },
        properties = {
            opacity = 0.95,
        },
    },
    { -- Launchers, no border or taskbar
        rule = {
            class = "albert",
        },
        properties = {
            border_width = 0,
            skip_taskbar = true,
            placement = function(c)
                return awful.placement.centered(c, {
                    offset = {
                        y = -(c.screen.workarea.height / 5),
                    },
                })
            end,
        },
    },

    -- monodevelop
    {
        rule = {
            class = "XTerm",
            name = "MonoDevelop External Console",
        },
        properties = {
            floating = true,
            callback = function(c)
                -- Get screen dimensions
                local workingArea = awful.screen.focused().workarea
                -- Set window dimensions and position based on screen size...
                local newWidth = workingArea.width / 2
                c:geometry({
                    x = workingArea.width - newWidth,
                    y = workingArea.y,
                    width = newWidth,
                    height = (workingArea.height / 4 * 3)
                })
            end,
        },
    },
    {
        rule = {
            class = "MonoDevelop",
            skip_taskbar = true,
        },
        properties = {
            border_width = 0
        },
    },

    -- spacefm
    { -- TODO: not working...
        rule = {
            class = "Spacefm",
            name = "Choose Application",
        },
        properties = {
            callback = function(c) c:geometry({width = 500, height = 600}) end,
        },
    },

    -- google chrome
    -- TODO: setup for chrome if we need it
    -- {
    --     rule = {
    --         class = "Chromium",
    --         role = "bubble",
    --     },
    --     properties = {
    --         floating = true,
    --     },
    -- },
    {
        rule = {
            class = "Google-chrome",
        },
        properties = {
            -- NOTE: this should have been caught by the global rules...
            maximized = false,

            keys = require("keybindings.clients.chromium"),
            callback = function(c)
                -- Function to recheck name
                name_callback[c] = function(c)
                    -- Check what the new name is
                    if string.find(c.name, "Tab Organizer") then -- Properties
                        c.floating = true

                        -- Change Size
                        local screenDimens = awful.screen.focused().workarea
                        local screenHeight = screenDimens.height
                        c:geometry({width = screenDimens.width - (2 * beautiful.border_width), height = screenHeight / 2, y = screenHeight/  4, x=0})
                    else
                        -- Print Name So I Can Possibly Change Other Names
                        -- notifySend(debugPrint(c.name), 2)
                    end
                    -- Clear Client From Callback Array
                    c:disconnect_signal("property::name", name_callback[c])
                    name_callback[c] = nil
                end
                -- Connect Function
                c:connect_signal("property::name", name_callback[c])
            end
        },
    },

    -- sublime
    {
        rule = {
            type = "dialog",
        },
        except_any = {
            name = {
                "O", "S", "E"
            },
        },
        properties = {
            callback = function(c)
                -- NOTE: except_any didn't seem to actually be behaving as I expected and was matching on a leafpad window, so we're doing the class check here instead
                if tableIndexOf({"Subl3", "Sublime_text"}, c.class) == nil then
                    return
                end

                -- TODO: Fix this up...
                local geom = c:geometry()
                if geom.width == 924 and geom.height == 282 then
                    c:kill();
                end
                notifySend("Sublime\nHis name was Robert.. Oh I Mean '".. (c.name or "nil") .."'", 3);
            end
        },
    },
    {
        rule_any = {
            class = {"Subl3", "Sublime_text"},
        },
        except_any = {
            type = {
                "dialog"
            },
        },
        properties = {
            switchtotag = true,
            callback = function(c)
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
                            c:move_to_tag(tags[tag]) -- TODO: If I wanted to support having clients on multiple tags, would need to change this and other stuff here...
                            break
                        end
                    end
                end
            end,
        },
    },

    -- seafile
    {
        rule = {
            class = "Seafile-applet",
            type = "normal",
        },
        properties = {
            border_width = 0,
            callback = function(c)
                local screenDimens = awful.screen.focused().workarea
                local width = 322 -- TODO: Should probably get the actual size OR the actual minimum
                local height = 883
                c:geometry({
                    x = screenDimens.width - width,
                    y = screenDimens.y,
                    width = width,
                    height = height,
                })
            end,
        },
    },
    {
        rule = {
            class = "Seafile-applet",
            type = "dialog",
        },
        properties = {
            callback = function(c)
                local screenDimens = awful.screen.focused().workarea
                local clientDimens = c:geometry()
                c:geometry({
                    x = (screenDimens.width - clientDimens.width) / 2,
                    y = (screenDimens.height - clientDimens.height) / 2,
                })
            end
        },
    },

    -- pavucontrol
    {
        rule = {
            class = "Pavucontrol",
        },
        properties = {
            callback = function(c)
                local existingDimens = c:geometry()
                local screenDimens = awful.screen.focused().workarea
                local width = existingDimens.width
                local height = existingDimens.height
                c:geometry({
                    x = screenDimens.width - width,
                    y = screenDimens.y,
                    width = width,
                    height = height,
                })
            end
        },
    },

    -- playonlinux
    {
        rule = {
            name = "PlayOnLinux Warning",
        },
        properties = {
            callback = function(c) c:kill() end,
        },
    },

    -- nautilus
    {
        rule = {
            class = "Nautilus",
            name = "File Operations",
        },
        properties = {
            ontop = true,
        },
    },

    -- gtk file chooser dialog
    {
        rule = {
            role = "GtkFileChooserDialog",
        },
        properties = {
            callback = function(c)
                -- Change Size of Normal Window Only
                -- if c.type == "floating" then
                    -- existingDimens = c:geometry()
                    local screenDimens = awful.screen.focused().workarea
                    local height = screenDimens.height * 0.75
                    c:geometry({
                        y = (screenDimens.height - height) / 2,
                        width = screenDimens.width * 0.5,
                        height = height,
                    })
                -- end
            end
        },
    },

    -- Android Studio - dialogs
    {
        rule = {
            class = "jetbrains-studio",
            type = "dialog",
        },
        properties = {
            floating = true,
        },
    },

    -- TODO: Add a rule so that the toggle-able windows are floating by default
}
