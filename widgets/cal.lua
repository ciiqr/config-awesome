local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")
local calendar_popup = require('awful.widget.calendar_popup')

local defaultStyle = {
    bg_color = beautiful.bg_focus,
    border_width = 0,
    padding = 2,
}

local roundedRect = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, beautiful.rounded_rect_corner_radius)
end

-- create calendar
local cal = calendar_popup.month({
    position = 'tc',
    -- @tparam string args.bg Wibox background color
    -- @tparam string args.font Calendar font
    -- @tparam number args.spacing Calendar spacing
    week_numbers = false,
    start_sunday = true,
    long_weekdays = true,
    style_month = gears.table.join(defaultStyle, {
        border_width = beautiful.border_width,
    }),
    style_header = defaultStyle,
    style_weekday = defaultStyle,
    style_weeknumber = defaultStyle,
    style_normal = gears.table.join(defaultStyle, {
        border_width = beautiful.border_thin_width,
        shape = roundedRect,
    }),
    style_focus = gears.table.join(defaultStyle, {
        border_width = beautiful.border_thin_width,
        shape = roundedRect,
        markup = string.format(
            '<span foreground="%s" background="%s" underline="%s"><b>%s</b></span>',
            beautiful.fg_focus,
            beautiful.bg_focus,
            'single',
            "%s"
        )
    }),
})

function cal.register(mywidget)
    -- hover shows
    local toggle = function(visible)
        return function()
            cal:call_calendar(0)
            cal.visible = visible
        end
    end
    mywidget:connect_signal('mouse::enter', toggle(true))
    mywidget:connect_signal('mouse::leave', toggle(false))

    -- clicks go back/forth through time
    mywidget:buttons(gears.table.join(
        awful.button({ }, 1, function (k, l) debugPrint(k);cal:call_calendar(-1) end),
        awful.button({ }, 3, function () cal:call_calendar( 1) end),
        awful.button({"Shift"}, 1, function () cal:call_calendar(-1) end),
        awful.button({"Shift"}, 3, function () cal:call_calendar( 1) end)
    ))
end

return cal
