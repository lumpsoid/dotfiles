local awful = require("awful")
local naughty = require("naughty")

local M = {}

function M.new()
    local self = {}
    local widget = nil
    local noti_obj = nil
    
    -- Commands for brightness control
    local cmd = {
        get = "bar--brightness-info",
        set = "brightnessctl s",
        inc = "brightnessctl s +2%",
        dec = "brightnessctl s 2%-"
    }
    
    -- Get current brightness level
    self.get_level = function(callback)
       awful.spawn.easy_async(cmd.get, function(out)
            level = math.floor(tonumber(out or 0))
            callback(level)
        end)
    end
    
    -- Common action function for brightness operations
    local function action(command)
        awful.spawn.easy_async(command, function()
            self.get_level(function(level)
                local text = "Brightness: " .. level .. "%"
                
                -- Emit signal to update widget if exists
                if widget then
                    widget:emit_signal("brightness::update", level)
                end
                
                -- Show notification
                noti_obj = naughty.notify({
                    replaces_id = noti_obj ~= nil and noti_obj.id or nil,
                    text = text,
                })
            end)
        end)
    end
    
    -- Brightness control functions
    self.update = function() action(cmd.get) end
    self.increase = function() action(cmd.inc) end
    self.decrease = function() action(cmd.dec) end
    self.set = function(value) action(cmd.set .. " " .. value) end
    
    -- Set the widget to update
    self.set_widget = function(w) widget = w end
    
    return self
end

return M
