require("awful.autofocus")
require("awful.remote")
require("utils.debug")
require("utils.functions")
require("enums")
require("errors")

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

-- TODO: globals, clean up
CONFIG = require("config")
THEME_PATH = gears.filesystem.get_configuration_dir() .. "theme"

-- Theme
beautiful.init(THEME_PATH .. "/theme.lua")

-- Layouts
awful.layout.layouts = require("layouts")

-- Global Keys
root.keys(require("keybindings.global"))

-- Rules
awful.rules.rules = require("rules")

-- Signals
setupSignals()

-- Startup Programs
startupPrograms()
