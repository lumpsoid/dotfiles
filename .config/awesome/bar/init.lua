-- Minimal flat top bar.
--
--   1 2 3            12:04              lum  vol  bat   Sun Jul 13
--
-- Flat single strip, no floating segments. Only occupied/selected
-- tags are shown. Hardware widgets are driven by singleton
-- controllers so the same instances back the media keys (see config/keys).
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local volume     = require("bar.volume")
local battery    = require("bar.battery")
local brightness = require("bar.brightness")

local M = {}

-- Singleton controllers shared with the keybindings.
M.controllers = {
  volume     = volume.controller.new(),
  battery    = battery.controller.new({ notify = true }),
  brightness = brightness.controller.new(),
}

-- Only surface tags that matter: the selected one and any with clients.
local function relevant_tags(t)
  return t.selected or #t:clients() > 0
end

-- Minimal text layout indicator: a single glyph per layout instead of the
-- busy default pixmap. Left-click cycles layouts, right-click cycles back.
local layout_glyph = {
  tile          = "[]=", -- master + stack
  tilebottom    = "[]v", -- master on top, stack below
  fairh         = "[+]", -- equal-width grid
  magnifier     = "[o]", -- focused enlarged
  max           = "[ ]", -- fullscreen (monocle)
  floating      = "><>", -- free placement
}

local function build_layoutbox(s)
  local w = wibox.widget.textbox()
  w.font = beautiful.font
  local function update()
    local name = awful.layout.getname(awful.layout.get(s))
    w.markup = '<span foreground="' .. beautiful.kanagawa.fujiGray .. '">'
      .. (layout_glyph[name] or name) .. "</span>"
  end
  update()
  tag.connect_signal("property::layout", update)
  tag.connect_signal("property::selected", update)
  w.buttons = {
    awful.button({}, 1, function() awful.layout.inc(1, s) end),
    awful.button({}, 3, function() awful.layout.inc(-1, s) end),
  }
  return w
end

local function build_taglist(s)
  return awful.widget.taglist({
    screen  = s,
    filter  = relevant_tags,
    style   = { shape = gears.shape.rectangle },
    layout  = { layout = wibox.layout.fixed.horizontal, spacing = beautiful.spacing },
    buttons = {
      awful.button({}, 1, function(t) t:view_only() end),
      awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
      end),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
      awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
    },
    widget_template = {
      {
        { id = "text_role", widget = wibox.widget.textbox },
        left = beautiful.spacing, right = beautiful.spacing,
        widget = wibox.container.margin,
      },
      id     = "background_role",
      widget = wibox.container.background,
    },
  })
end

local function per_screen(s)
  awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

  -- Invisible until modkey+r; kept for the run prompt.
  s.mypromptbox = awful.widget.prompt()

  -- Hardware widgets, wired to the shared controllers.
  local brightness_w = brightness.createWidget({})
  local volume_w     = volume.createWidget({})
  local battery_w    = battery.createWidget({})
  M.controllers.brightness.set_widget(brightness_w)
  M.controllers.volume.set_widget(volume_w)
  M.controllers.battery.set_widget(battery_w)

  -- Silent initial read (no notification) so widgets show real values.
  -- Battery primes itself via its own timer/call_now.
  M.controllers.volume.get_level(function(level, status)
    volume_w:emit_signal("volume::update", level, status)
  end)
  M.controllers.brightness.get_level(function(level)
    brightness_w:emit_signal("brightness::update", level)
  end)
  M.controllers.battery.get_status(function(charge, status)
    battery_w:emit_signal("battery::update", charge, status)
  end)

  local clock = wibox.widget.textclock('<span foreground="' .. beautiful.fg_normal .. '">%H:%M</span>')
  clock.font = beautiful.font
  local date = wibox.widget.textclock('<span foreground="' .. beautiful.kanagawa.fujiGray .. '">%a %b %d</span>')
  date.font = beautiful.font

  s.mywibar = awful.wibar({
    position = "top",
    screen   = s,
    height   = beautiful.bar_height,
    bg       = beautiful.bar_bg,
    widget   = {
      {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- left
          layout = wibox.layout.fixed.horizontal,
          spacing = beautiful.spacing_md,
          build_taglist(s),
          s.mypromptbox,
        },
        clock, -- center (align + expand="none" keeps it centered)
        { -- right
          layout  = wibox.layout.fixed.horizontal,
          spacing = beautiful.spacing_md,
          build_layoutbox(s),
          brightness_w,
          volume_w,
          battery_w,
          date,
          wibox.widget.systray(),
        },
      },
      left   = beautiful.spacing_lg,
      right  = beautiful.spacing_lg,
      widget = wibox.container.margin,
    },
  })
end

function M.setup()
  screen.connect_signal("request::desktop_decoration", per_screen)
end

return M
