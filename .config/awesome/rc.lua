-- awesome_mode: api-level=4:screen=on
-- Thin entry point. Real configuration lives in config/ and bar/.
pcall(require, "luarocks.loader")

local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")
local menubar   = require("menubar")
require("awful.autofocus")

local constants = require("constants")

-- Theme first: everything below reads beautiful.*
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Globals a few subsystems still expect.
terminal   = constants.terminal
editor     = os.getenv("EDITOR") or constants.editor
editor_cmd = constants.editor_cmd
modkey     = constants.mods.m
menubar.utils.terminal = terminal

-- Load order: errors, layouts, look, behaviour, bar.
require("config.error")
require("config.layouts")
require("config.wallpaper")
require("config.notifications")
require("config.rules")
require("config.keys")
require("bar").setup()
require("config.autostart")

-- Sloppy focus: focus follows the mouse.
client.connect_signal("mouse::enter", function(c)
  c:activate({ context = "mouse_enter", raise = false })
end)
