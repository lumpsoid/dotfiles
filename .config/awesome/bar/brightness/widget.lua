local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

function dump_table(t)
    local result = ""
    for k, v in pairs(t) do
        result = result .. k .. ": " .. tostring(v) .. "\n"
    end
    return result
end

local function get_icon(level)
    level = tonumber(level or 0)
    
    if level >= 75 then
        return "☀"  -- Bright
    elseif level >= 40 then
        return "🔆"  -- Medium
    else
        return "🔅"  -- Low
    end
end

local function colorize_text(text, color)
    return string.format('<span color="%s">%s</span>', color, text)
end

local function new(buttons)
    local current = {
        level = 50
    }
    
    -- Create icon widget
    local icon = wibox.widget({
        markup = get_icon(current.level),
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
    local function update_widget(widget, level)
       
       if current.level ~= level then
            current.level = level
            
            icon.markup = colorize_text(get_icon(level), beautiful.fg_normal)
            percentage.text = level .. "%"
        end
    end
    
    -- Connect to the update signal
    widget:connect_signal("brightness::update", update_widget)
    
    return widget
end

return new
