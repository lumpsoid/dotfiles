local wibox = require("wibox")
local beautiful = require("beautiful")

-- Nerd Font (Font Awesome) sun glyph as decimal UTF-8 (LuaJIT-safe).
local SUN = "\239\134\133" -- nf-fa-sun_o

local function markup(text, color)
  return string.format('<span foreground="%s">%s</span>', color, text)
end

local function new(buttons)
  local current = { level = 50 }

  local icon = wibox.widget({
    markup = markup(SUN, beautiful.fg_normal),
    font   = beautiful.font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local percentage = wibox.widget({
    text   = current.level .. "%",
    font   = beautiful.font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local widget = wibox.widget({
    icon,
    percentage,
    buttons = buttons,
    spacing = beautiful.spacing,
    layout  = wibox.layout.fixed.horizontal,
  })

  local function update(_, level)
    if current.level ~= level then
      current.level = level
      percentage.text = level .. "%"
    end
  end

  widget:connect_signal("brightness::update", update)
  return widget
end

return new
