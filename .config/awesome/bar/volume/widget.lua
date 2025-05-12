local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local M = {}

local ICONS = {
    high = "🔊",
    medium = "🔉",
    low = "🔈",
    mute = "🔇"
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

local function colorize_text(text, color)
    return string.format('<span color="%s">%s</span>', color, text)
end

function M.new(buttons)
    local current = {
        level = 50,
        status = "on"
    }
    
    -- Create icon widget
    local icon = wibox.widget({
        markup = get_icon(current.level, current.status),
        font = beautiful.font,
        forced_width = beautiful.icon_size or 24,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })
    
    -- Create percentage widget
    local percentage = wibox.widget({
        text = current.level .. "%",
        font = beautiful.font,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })
    
    -- Create the combined widget
    local widget = wibox.widget({
        icon, 
        percentage,
        buttons = buttons,
        spacing = beautiful.spacing or 4,
        layout = wibox.layout.fixed.horizontal,
    })
    
    -- Update widget function
    local function update_widget(widget, level, status)
        if current.level ~= level or current.status ~= status then
            current.level = level
            current.status = status
            
            icon.markup = colorize_text(get_icon(level, status), beautiful.fg_normal)
            percentage.text = level .. "%"
        end
    end
    
    -- Connect to the update signal
    widget:connect_signal("volume::update", update_widget)
    
    return widget
end

return M
