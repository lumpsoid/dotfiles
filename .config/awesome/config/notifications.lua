-- Notification styling and defaults.
local naughty = require("naughty")
local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")
local gears = require("gears")

ruled.notification.connect_signal("request::rules", function()
  ruled.notification.append_rule({
    rule       = {},
    properties = {
      screen           = awful.screen.preferred,
      implicit_timeout = 5,
      position         = "top_right",
    },
  })
end)

naughty.connect_signal("request::display", function(n)
  naughty.layout.box({
    notification = n,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
    end,
  })
end)
