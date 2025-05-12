local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local ICONS = {
    charging = "⚡",
    full = "■",
    high = "▣",
    medium = "▢",
    low = "▭",
    critical = "□",
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

local function colorize_text(text, color)
    return string.format('<span color="%s">%s</span>', color, text)
end

local function new()
    local current = {
        charge = 100,
        status = "Full"
    }
    
    -- Create icon widget
    local icon = wibox.widget({
        markup = get_icon(current.charge, current.status),
        font = beautiful.font,
        forced_width = beautiful.icon_size or 24,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })
    
    -- Create percentage widget
    local percentage = wibox.widget({
        text = current.charge .. "%",
        font = beautiful.font,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })
    
    -- Create the combined widget
    local widget = wibox.widget({
        icon, 
        percentage,
        spacing = beautiful.spacing or 4,
        layout = wibox.layout.fixed.horizontal,
    })
    
    -- Update widget function
    local function update_widget(widget, charge, status)
        if current.charge ~= charge or current.status ~= status then
            current.charge = charge
            current.status = status
            
            -- Update color based on charge level
            local color = beautiful.fg_normal
            if status ~= "Charging" and charge < 15 then
                color = "#FF0000"  -- Red for critical
            elseif status ~= "Charging" and charge < 30 then
                color = "#FFAA00"  -- Orange for low
            end
            
            icon.markup = colorize_text(get_icon(charge, status), color)
            percentage.text = charge .. "%"
        end
    end
    
    -- Connect to the update signal
    widget:connect_signal("battery::update", update_widget)
    
    return widget
end

return new
