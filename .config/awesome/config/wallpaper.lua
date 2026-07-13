-- Minimal: a solid, calm fill. No image, no distraction.
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper({
    screen = s,
    bg     = beautiful.kanagawa.sumiInk0,
    widget = wibox.widget({
      bg     = beautiful.kanagawa.sumiInk0,
      widget = wibox.container.background,
    }),
  })
end)
