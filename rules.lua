local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local binding = require("utils.binding")

local name_callback = {}

-- TODO: improve
-- TODO: extract client keys/buttons

--Keys
local environment = {
    client = require("actions.client"),
}
-- Client Key Bindings
local keys = binding.createKeys(CONFIG.client.keybindings, environment)
local clientkeys = gears.table.join(unpack(keys))

--Buttons
local clientButtons = gears.table.join(
    awful.button({}, MOUSE_LEFT, function(c) client.focus = c; c:raise() end)-- Click Focuses & Raises
    ,awful.button({SUPER}, MOUSE_LEFT, awful.mouse.client.move)              -- Super + Left Moves
    -- ,awful.button({}, MOUSE_MIDDLE, awful.mouse.client.move)              -- Middle Moves -- TODO: I can't currently use this because it conflicts with 'Insert' paste... (if I can convince Insert to be been as shift+Insert then maybe I can enable this...)
    ,awful.button({SUPER}, MOUSE_RIGHT, awful.mouse.client.resize)               -- Super + Right Resizes
    ,awful.button({CONTROL}, MOUSE_SCROLL_UP, function()end) -- Prevent ctrl-scroll zoom
    ,awful.button({CONTROL}, MOUSE_SCROLL_DOWN, function()end) -- Prevent ctrl-scroll zoom
)

return {
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
                local workingArea = awful.screen.focused().workarea
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
    ,{
        rule = {
            class = "Chromium",
        },
        properties = {
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
                    elseif string.find(c.name, "Select the email service you use") then -- Properties
                        c.floating = true
                    elseif string.find(c.name, "Hangouts") then -- Properties
                        c.floating = false
                        -- -- On Social Tag
                        -- local tags = c.screen.tags
                        -- c:move_to_tag(tags[6]) -- TODO: Add constant for Social Tag Index...
                    else
                        -- Print Name So I Can Possibly Change Other Names
                        -- notify_send(debug_print(c.name), 2)
                    end
                    -- Clear Client From Callback Array
                    c:disconnect_signal("property::name", name_callback[c])
                    name_callback[c] = nil
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
                            c:move_to_tag(tags[tag]) -- TODO: If I wanted to support having clients on multiple tags, would need to change this and other stuff here...
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
                local screenDimens = awful.screen.focused().workarea
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
                local screenDimens = awful.screen.focused().workarea
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
                local screenDimens = awful.screen.focused().workarea
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
                local screenDimens = awful.screen.focused().workarea
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
    -- ,{
    --     rule_any = {
    --         class = {"Skype", "yakyak"},
    --     },
    --     properties = {
    --         tag = awful.screen.focused().tags[6]
    --         -- callback = function(c)
    --         --  -- Floating Windows have a north west gravity, others have static
    --         --  -- False Assumption
    --         --  -- if c.size_hints.win_gravity == "north_west" then
    --         --  --  c.floating = true
    --         --  -- end
    --         -- end
    --     }
    -- }
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
            callback = function(c) c.fullscreen = true end
        }
    }
    -- ,{
    --     rule_any = {
    --         class = {"Vmware"},
    --         instance = {"TeamViewer.exe"}
    --     },
    --     properties = {
    --         tag = awful.screen.focused().tags[5]
    --     }
    -- }
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
            callback = function(c)
                -- Change Size of Normal Window Only
                -- if c.type == "floating" then
                    -- existingDimens = c:geometry()
                    local screenDimens = awful.screen.focused().workarea
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
