local awful = require("awful")
local naughty = require("naughty")

local M = {}

function M.new()
    local self = {}
    local widget = nil
    local noti_obj = nil
    
    -- Commands for volume control
    local cmd = {
       get = "echo '[50] [status]'",
       set = "echo '[20] [statusnew]'",
       inc = "echo '[60] [statusdd]'",
       dec = "echo '[40] [statusxxx]'",
        toggle = "echo '[Muted]'"
    }
    
    -- Get current volume level and status
    self.get_level = function(callback)
        awful.spawn.easy_async(cmd.get, function(out)
            local level, status = string.match(out, "%[(%d+)%%%] %[(%a+)%]")
            callback(level, status)
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
                    widget:emit_signal("update", level, status)
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
