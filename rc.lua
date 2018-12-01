require("awful.autofocus")
require("awful.remote")
require("utils.lua")
require("utils.awesome")
require("utils.config")
require("enums")

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

-- TODO: globals, clean up
CONFIG = require("config")
WIDGET_MANAGER = require("widgets.manager") -- TODO: fix CONFIG
THEME_PATH = gears.filesystem.get_configuration_dir() .. "theme"

-- Theme
beautiful.init(THEME_PATH .. "/theme.lua")

-- Layouts
awful.layout.layouts = require("layouts")

-- Global Keys
root.keys(require("keybindings"))

-- Rules
awful.rules.rules = require("rules")

-- Signals
setupSignals()

-- Startup Programs
startupPrograms()
