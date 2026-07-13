local wibox = require("wibox")
local beautiful = require("beautiful")

local M = {}

-- Nerd Font (Font Awesome) glyphs as decimal UTF-8 (LuaJIT-safe).
local ICONS = {
  high   = "\239\128\168", -- nf-fa-volume_up
  medium = "\239\128\167", -- nf-fa-volume_down
  low    = "\239\128\167", -- nf-fa-volume_down
  mute   = "\239\128\166", -- nf-fa-volume_off
}

local function get_icon(level, status)
  level = tonumber(level or 0)
  if status == "off" then
    return ICONS.mute
  elseif level >= 75 then
    return ICONS.high
  elseif level >= 40 then
    return ICONS.medium
  else
    return ICONS.low
  end
end

local function markup(text, color)
  return string.format('<span foreground="%s">%s</span>', color, text)
end

function M.new(buttons)
  local current = { level = 50, status = "on" }

  local icon = wibox.widget({
    markup = markup(get_icon(current.level, current.status), beautiful.fg_normal),
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

  local function update(_, level, status)
    if current.level ~= level or current.status ~= status then
      current.level, current.status = level, status
      local color = status == "off" and beautiful.muted or beautiful.fg_normal
      icon.markup = markup(get_icon(level, status), color)
      percentage.text = level .. "%"
    end
  end

  widget:connect_signal("volume::update", update)
  return widget
end

return M
