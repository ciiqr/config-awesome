-------------------------------
-- Custom Theme for Awesome WM
--
-- William Villeneuve
--
-- Alternative icon sets and widget icons:
-- http://awesome.naquadah.org/wiki/Nice_Icons

-- Overriding the defaults:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- theme.taglist_bg_focus = "#CC9393"f


-- To TRY
-- 6E533F

-- TODO: Is there a way we can set theme settings like this per-screen and update them as appropriate (when windows change screen for example, blah...)
-- TODO: Also have a function for this, and also use it in rc.lua
local dpi = require("beautiful.xresources").apply_dpi
local scale_factor = dpi(1)
local scale_factor_path = scale_factor ~= 1 and "@"..scale_factor.."x" or ""

-- Colors --
--========--
local currentScheme = "blue, yellow highlights"
local colourSchemes = {
    ["red"] = {
        lightColour = "#97281C",
        darkColour = "#581109",
    },
    ["orange"] = {
        lightColour = "#DE7712",
        darkColour = "#C96508",
    },
    ["yellow"] = {
        lightColour = "#F4E210",
        darkColour = "#bf7900",
    },
    ["green"] = {
        lightColour = "#3F923A",
        darkColour = "#22511F",
    },
    ["blue"] = {
        lightColour = "#218fbd",
        darkColour = "#005577",
    },
    ["purple"] = {
        lightColour = "#8512DE",
        darkColour = "#3F175E",
    },
    ["natural"] = {
        lightColour = "#92803A",
        darkColour = "#453D1C",
    },
    ["sea"] = {
        lightColour = "#23CDC0",
        darkColour = "#EDC9AF",
    },
    ["calm"] = {
        lightColour = "#f08080",
        darkColour = "#68838b",
    },
    ["red, yellow highlights"] = {
        lightColour = "#FFC629",
        darkColour = "#5A0000",
    },
    ["blue, yellow highlights"] = {
        lightColour = "#FFC629",
        darkColour = "#68838b",
    },
}
local scheme = colourSchemes[currentScheme] or {}
local lightColour = scheme.lightColour or "#97281C"
local darkColour = scheme.darkColour or "#581109"
local white = "#FFFFFF"
local black = "#000000"
local paleYellow = "#DCDCCC" -- Almost White
local lightRed = "#CD2323"
local darkGrey = "#3F3F3F"
local slightlyLighterGrey = "#424242" -- Matches GTK Theme


-- Variables --
--===========--
-- BAR_TRANSPARENCY = true
local themePathLayouts = THEME_PATH .. "/layouts/"

local theme = {
    -- Fonts
    font = "DejaVu Sans Book 9", -- Roboto 9
    -- font_bold = "sans bold 10",
    -- tasklist_font = "DejaVu Sans Book 9",

    -- Colours
    fg_normal  = paleYellow, -- Normal Text Colour
    fg_focus   = lightColour, --"#F0DFAF"
    fg_urgent  = lightRed,

    bg_normal  = black..ternary(BAR_TRANSPARENCY, "00", "7e"),
    bg_focus   = "#222222"..ternary(BAR_TRANSPARENCY, "00", "FF"), --222222ee -- bg_focus   = bg_normal --"#66666677"
    bg_urgent  = darkGrey,

    -- Borders
    border_width  = dpi(2),
    border_thin_width = dpi(1),
    border_normal = darkGrey,
    border_focus  = darkColour,
    border_marked = lightRed,

    -- Tasklist
    tasklist_bg_focus = darkColour,
    tasklist_fg_normal = white,
    tasklist_fg_focus = black,

    -- TagList
    taglist_fg_focus = lightColour,
    -- TODO: If I ever switch to a 1..2 px high bar, use this to show a colour on the selected tag even if there arn't any windows: taglist_bg_focus = "#888888",

    -- System Tray
    bg_systray = ternary(BAR_TRANSPARENCY, "#2b2726", black), -- bg_normal


    -- Icons --
    --=======--
    -- Taglist
    taglist_squares_sel   = THEME_PATH .. "/taglist/squarefz-double-height"..scale_factor_path..".png",
    taglist_squares_unsel = THEME_PATH .. "/taglist/squarez"..scale_factor_path..".png",
    taglist_squares_resize = "true",

    -- Layout
    layout_tile       = themePathLayouts .. "tile.png",
    layout_fairv      = themePathLayouts .. "fairv.png",
    layout_fairh      = themePathLayouts .. "fairh.png",
    layout_max        = themePathLayouts .. "max.png",
    layout_floating   = themePathLayouts .. "floating.png",
    layout_thrizen    = gears.filesystem.get_configuration_dir() .. "/layouts/thrizen/themes/default/thrizen.png",

    -- layout details
    column_count = 3,
    master_width_factor = 1/3,

    --
    panel = {
        height = function(screen)
            return dpi(15, screen)
        end
    },

    spacer_size = 14,

    rounded_rect_corner_radius = dpi(4),

    global_windows_list_width = dpi(300),
    system_info_width = dpi(120),
}

return theme
