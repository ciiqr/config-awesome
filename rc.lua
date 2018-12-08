require("awful.autofocus")
require("awful.remote")
require("utils.debug")
require("utils.functions")
require("enums")
require("errors")

local awful = require("awful")
local theme = require("theme")
local layouts = require("layouts")
local keybindings = require("keybindings")
local events = require("events")

-- TODO: globals, clean up
CONFIG = require("config")

-- Theme
theme.init()

-- Layouts
layouts.init()

-- Keybindings
keybindings.init()

-- Rules
awful.rules.rules = require("rules")

-- Events
events.init()

-- Screens
setupScreens()

-- Startup Programs
startupPrograms()
