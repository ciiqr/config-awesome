require("awful.autofocus")
require("awful.remote")
require("utils.lua")
require("utils.awesome")
require("utils.config")
require("enums")
-- TODO: make more local
gears = require("gears")
awful = require("awful")
beautiful = require("beautiful")
naughty = require("naughty")
inspect = require("third-party.inspect") -- TODO: luarocks instead?
thrizen = require("layouts.thrizen")
CONFIG = require("config")
widget_manager = require("widgets.manager") -- TODO: fix CONFIG

-- Theme
THEME_PATH = gears.filesystem.get_configuration_dir() .. "/theme"
beautiful.init(THEME_PATH .. "/theme.lua")

-- Layouts
awful.layout.layouts = {
    thrizen,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
}

-- Screen Signals
screen.connect_signal("property::geometry", screenSetWallpaper)
awful.screen.connect_for_each_screen(screenInit)

-- Client Signals
client.connect_signal("manage", manageClient)
client.connect_signal("focus", clientDidFocus)
client.connect_signal("unfocus", clientDidLoseFocus)
client.connect_signal("property::floating", clientDidChangeFloating)
client.connect_signal("mouse::enter", clientDidMouseEnter)
setupClientRequestActivate()

-- Network Signals
setup_network_connectivity_change_listener()

-- Global Keys
root.keys(require("keybindings"))

-- Rules
awful.rules.rules = require("rules")

-- Startup Programs
startupPrograms()
