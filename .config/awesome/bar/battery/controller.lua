local awful = require("awful")
local naughty = require("naughty")
local utils = require("utils")

local M = {}

function M.new(config)
    local self = {}
    local widget = nil
    local noti_obj = nil
    local notify_low = config and config.notify or true
    local bat_num = config and config.bat_item or 1
    
    -- Get battery status
    self.get_status = function(callback)
        local cmd = "bar--battery-info BAT1"
        awful.spawn.easy_async(cmd, function(out)
        local charge_str, status = table.unpack(utils.split_by_newline(out))
        local charge = tonumber(charge_str) or 0

        callback(charge, status)
        end)
    end
    
    -- Periodic update function
    local function check_battery()
       self.get_status(function(charge, status)
            -- Emit signal to update widget if exists
            if widget then
                widget:emit_signal("battery::update", charge, status)
            end
            
            -- Show notification if battery low
            if notify_low and charge < 25 and status == "Discharging" then
                noti_obj = naughty.notify({
                    replaces_id = noti_obj ~= nil and noti_obj.id or nil,
                    title = "Battery Low",
                    text = "Battery at " .. charge .. "%, please connect charger",
                    urgency = "critical",
                })
            end
        end)
    end
    
    -- Set up timer for battery monitoring
    local bat_timer = timer({ timeout = 60 })
    bat_timer:connect_signal("timeout", check_battery)
    bat_timer:start()
    
    -- Initial check
    check_battery()
    
    -- Set the widget to update
    self.set_widget = function(w) widget = w end
    
    return self
end

return M
