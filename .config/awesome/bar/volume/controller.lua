local awful = require("awful")
local naughty = require("naughty")

local M = {}

function M.new()
    local self = {}
    local widget = nil
    local noti_obj = nil
    
    -- Commands for volume control
    local cmd = {
       get = "bar--volume-info",
       set = "l--volume-control change",
       inc = "l--volume-control change 3%+",
       dec = "l--volume-control change 3%-",
       toggle = "l--volume-control toggle"
    }
    
    -- Get current volume level and status
    self.get_level = function(callback)
   awful.spawn.easy_async(cmd.get, function(out)
        -- Find the position of the newline
        local nl_pos = string.find(out, "\n")
        
        if nl_pos then
            -- Extract level from first line
            local level = tonumber(string.sub(out, 1, nl_pos - 1)) or 0
            
            -- Extract mute status from second line
            local is_muted = string.sub(out, nl_pos + 1)
            local status = "on"
            if string.find(is_muted, "yes") then
                status = "off"
            end
            
            callback(level, status)
        else
            naughty.notify({
                text = "Error parsing volume output: " .. out,
            })
        end
    end)
end
    
    -- Common action function for volume operations
    local function action(command)
       awful.spawn.easy_async(command, function()
                                 
         self.get_level(function(level, status)

                local percentage = level .. "%"
                local text = status == "on" and "Volume: " .. percentage or "[Muted] " .. percentage
                
                -- Emit signal to update widget if exists
                 if widget then
                    widget:emit_signal("volume::update", level, status)
                end
                
                -- Show notification
                noti_obj = naughty.notify({
                    replaces_id = noti_obj ~= nil and noti_obj.id or nil,
                    text = text,
                })
            end)
        end)
    end
    
    -- Volume control functions
    self.increase = function() action(cmd.inc) end
    self.decrease = function() action(cmd.dec) end
    self.toggle = function() action(cmd.toggle) end
    
    -- Set the widget to update
    self.set_widget = function(w) widget = w end
    
    return self
end

return M
