require("awful.autofocus")
require("awful.remote")
require("utils.debug")
require("utils.functions")
require("enums")
require("errors")

local awful = require("awful")
local theme = require("theme")

-- TODO: globals, clean up
CONFIG = require("config")

-- Theme
theme.init()

-- Layouts
awful.layout.layouts = require("layouts")

-- Global Keys
root.keys(require("keybindings.global"))

-- Rules
awful.rules.rules = require("rules")

-- Signals
setupSignals()

-- Screens
setupScreens()

-- Startup Programs
startupPrograms()
