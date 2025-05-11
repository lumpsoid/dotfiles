local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local separator = wibox.widget {
    widget = wibox.widget.separator,
    orientation = "vertical",
    forced_width = 1,
    color = "#444444",
}

screen.connect_signal(
   "request::desktop_decoration",
   function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    -- Create a textclock widget for the center
    local mytextclock = wibox.widget.textclock("%a %b %d, %H:%M")
    
    -- Create containers for your script outputs on the right
    local cpu_widget = awful.widget.watch('bash -c "sb-cpu"', 5)
    local memory_widget = awful.widget.watch('bash -c "sb-memory"', 10)
    local weather_widget = awful.widget.watch('bash -c "sb-weather"', 1800)
    local sound_widget = awful.widget.watch('bash -c "sc-volume"', 5)
    local brightness_widget = awful.widget.watch('bash -c "bar--brightness"', 5)

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
       screen = s,
       filter = awful.widget.taglist.filter.noempty, -- This shows only non-empty tags
       buttons = {
          awful.button({ }, 1, function(t) t:view_only() end),
          awful.button({ modkey }, 1, function(t)
                if client.focus then
                   client.focus:move_to_tag(t)
                end
          end),
          awful.button({ }, 3, awful.tag.viewtoggle),
          awful.button({ modkey }, 3, function(t)
                if client.focus then
                   client.focus:toggle_tag(t)
                end
          end),
          awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
          awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
       }
    }
    s.mylayoutbox = awful.widget.layoutbox {
       screen  = s,
       buttons = {
          awful.button({ }, 1, function () awful.layout.inc( 1) end),
          awful.button({ }, 3, function () awful.layout.inc(-1) end),
          awful.button({ }, 4, function () awful.layout.inc(-1) end),
          awful.button({ }, 5, function () awful.layout.inc( 1) end),
       }
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
       position = "top",
       screen   = s,
       widget   = {
          layout = wibox.layout.align.horizontal,
          { -- Left widgets
             layout = wibox.layout.fixed.horizontal,
             s.mytaglist, -- Only shows active tags
          },
          { -- Middle widget
             layout = wibox.layout.fixed.horizontal,
             separator, -- Add separator before the clock
             mytextclock,
             separator, -- Add separator after the clock
          },
          { -- Right widgets
             layout = wibox.layout.fixed.horizontal,
             cpu_widget,
             memory_widget,
             weather_widget,
             sound_widget,
             brightness_widget,
             wibox.widget.systray(),
             s.mylayoutbox,
          },
       }
    }
      
end)
