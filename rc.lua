require("awful.autofocus")
require("awful.remote")
require("utils.debug")
require("utils.functions")
require("enums")
require("errors")

local theme = require("theme")
local layouts = require("layouts")
local keybindings = require("keybindings")
local rules = require("rules")
local events = require("events")
local screens = require("screens")
local programs = require("programs")

-- TODO: globals, clean up
CONFIG = require("config")

-- pretty good, innit
theme.init()
layouts.init()
keybindings.init()
rules.init()
events.init()
screens.init()
programs.init()
