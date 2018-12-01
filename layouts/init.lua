local awful = require("awful")
local thrizen = require("layouts.thrizen")

return {
    thrizen,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
}
