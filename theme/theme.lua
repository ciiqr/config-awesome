-- My Custom Theme for Awesome WM

-- To TRY
-- 6E533F

-- TODO: Is there a way we can set theme settings like this per-screen and update them as appropriate (when windows change screen for example, blah...)
-- TODO: Also have a function for this, and also use it in rc.lua
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local scale_factor = dpi(1)
local scale_factor_path = scale_factor ~= 1 and "@"..scale_factor.."x" or ""

-- Colors --
local colourSchemes = {
    ["red"] = {
        alternateColour = "#97281C",
        primaryColour = "#581109",
        primaryColourContrast = "#FFFFFF",
    },
    ["orange"] = {
        alternateColour = "#DE7712",
        primaryColour = "#C96508",
        primaryColourContrast = "#000000",
    },
    ["yellow"] = {
        alternateColour = "#F4E210",
        primaryColour = "#bf7900",
        primaryColourContrast = "#000000",
    },
    ["green"] = {
        alternateColour = "#3F923A",
        primaryColour = "#22511F",
        primaryColourContrast = "#FFFFFF",
    },
    ["blue"] = {
        alternateColour = "#218fbd",
        primaryColour = "#005577",
        primaryColourContrast = "#FFFFFF",
    },
    ["purple"] = {
        alternateColour = "#8512DE",
        primaryColour = "#3F175E",
        primaryColourContrast = "#FFFFFF",
    },
    ["natural"] = {
        alternateColour = "#92803A",
        primaryColour = "#453D1C",
        primaryColourContrast = "#FFFFFF",
    },
    ["sea"] = {
        alternateColour = "#23CDC0",
        primaryColour = "#EDC9AF",
        primaryColourContrast = "#000000",
    },
    ["calm"] = {
        alternateColour = "#f08080",
        primaryColour = "#68838b",
        primaryColourContrast = "#000000",
    },
    ["red & yellow"] = {
        alternateColour = "#FFC629",
        primaryColour = "#5A0000",
        primaryColourContrast = "#FFFFFF",
    },
    ["blue & yellow"] = {
        alternateColour = "#FFC629",
        primaryColour = "#68838b",
        primaryColourContrast = "#000000",
    },
}
local scheme = colourSchemes[CONFIG.theme.colourScheme] or {}
local alternateColour = scheme.alternateColour or "#97281C"
local primaryColour = scheme.primaryColour or "#581109"
local primaryColourContrast = scheme.primaryColourContrast or "#000000";
local paleYellow = "#DCDCCC" -- Almost White
local lightRed = "#CD2323"
local darkGrey = "#3F3F3F"


-- Variables --
--===========--
local BAR_TRANSPARENCY = false
local themePath = beautiful.theme_path
local themePathLayouts = themePath .. "/layouts/"

local theme = {
    -- paths
    theme_path = themePath,

    -- Fonts
    font = "DejaVu Sans Book 9", --


    -- colours --
    ----------
    fg_normal  = paleYellow, -- Normal Text Colour
    fg_focus   = alternateColour, --"#F0DFAF"
    fg_urgent  = lightRed,

    bg_normal  = "#000000"..(BAR_TRANSPARENCY and "00" or "7e"),
    bg_focus   = "#222222"..(BAR_TRANSPARENCY and "00" or "FF"), --222222ee -- bg_focus   = bg_normal --"#66666677"
    bg_urgent  = darkGrey,

    -- Borders
    border_normal = darkGrey,
    border_focus  = primaryColour,
    border_marked = lightRed,

    -- Tasklist
    tasklist_bg_focus = primaryColour,
    tasklist_fg_normal = "#FFFFFF",
    tasklist_fg_focus = primaryColourContrast,

    -- TagList
    taglist_fg_focus = alternateColour,
    -- TODO: If I ever switch to a 1..2 px high bar, use this to show a colour on the selected tag even if there arn't any windows: taglist_bg_focus = "#888888",

    -- System Tray
    bg_systray = (BAR_TRANSPARENCY and "#2b2726" or "#000000"), -- bg_normal


    -- icons --
    -----------

    -- Taglist
    taglist_squares_sel   = themePath .. "/taglist/squarefz-double-height"..scale_factor_path..".png",
    taglist_squares_unsel = themePath .. "/taglist/squarez"..scale_factor_path..".png",
    taglist_squares_resize = "true",

    -- Layout
    layout_tile       = themePathLayouts .. "tile.png",
    layout_fairv      = themePathLayouts .. "fairv.png",
    layout_fairh      = themePathLayouts .. "fairh.png",
    layout_max        = themePathLayouts .. "max.png",
    layout_floating   = themePathLayouts .. "floating.png",
    layout_thrizen    = gears.filesystem.get_configuration_dir() .. "/layouts/thrizen/themes/default/thrizen.png",


    -- size --
    ----------

    -- layout details
    column_count = 2,
    master_width_factor = 1/3,

    -- naughty

    -- TODO: once this is released, I want it
    -- notification_icon_size = dpi(85),

    -- TODO: maybe these properties can be set based on screen via rules which we dynamically set/remove when screens are...
    -- Borders
    border_width  = dpi(2),
    border_thin_width = dpi(1),

    -- wibars
    panel = {
        height = function(screen)
            return dpi(15, screen)
        end
    },

    -- widgets
    spacer_size = 14,

    -- cal
    rounded_rect_corner_radius = dpi(4),

    -- wiboxes
    global_windows_list_width = dpi(300),
    system_info_width = dpi(120),
}

return theme
