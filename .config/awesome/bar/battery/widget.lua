local wibox = require("wibox")
local beautiful = require("beautiful")

-- Nerd Font (Font Awesome) glyphs as decimal UTF-8 (LuaJIT-safe).
local ICONS = {
  charging = "\239\131\167", -- nf-fa-bolt
  full     = "\239\137\128", -- nf-fa-battery_full
  high     = "\239\137\129", -- nf-fa-battery_three_quarters
  medium   = "\239\137\130", -- nf-fa-battery_half
  low      = "\239\137\131", -- nf-fa-battery_quarter
  critical = "\239\137\132", -- nf-fa-battery_empty
}

local function get_icon(charge, status)
  charge = tonumber(charge or 0)
  if status == "Charging" then
    return ICONS.charging
  elseif status == "Full" or charge >= 95 then
    return ICONS.full
  elseif charge >= 60 then
    return ICONS.high
  elseif charge >= 30 then
    return ICONS.medium
  elseif charge >= 15 then
    return ICONS.low
  else
    return ICONS.critical
  end
end

local function icon_color(charge, status)
  if status == "Charging" then
    return beautiful.battery_charging
  elseif status ~= "Charging" and charge < 15 then
    return beautiful.battery_sad
  elseif status ~= "Charging" and charge < 30 then
    return beautiful.battery_tired
  end
  return beautiful.battery_happy
end

local function markup(text, color)
  return string.format('<span foreground="%s">%s</span>', color, text)
end

local function new()
  local current = { charge = 100, status = "Full" }

  local icon = wibox.widget({
    markup = markup(get_icon(current.charge, current.status), beautiful.battery_happy),
    font   = beautiful.font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local percentage = wibox.widget({
    text   = current.charge .. "%",
    font   = beautiful.font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local widget = wibox.widget({
    icon,
    percentage,
    spacing = beautiful.spacing,
    layout  = wibox.layout.fixed.horizontal,
  })

  local function update(_, charge, status)
    if current.charge ~= charge or current.status ~= status then
      current.charge, current.status = charge, status
      icon.markup   = markup(get_icon(charge, status), icon_color(charge, status))
      percentage.text = charge .. "%"
    end
  end

  widget:connect_signal("battery::update", update)
  return widget
end

return new
