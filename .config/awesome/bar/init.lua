local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("utils")
local naughty = require("naughty")

local M = {}

-- Import components
M.volume = require("bar.volume")
M.battery = require("bar.battery")
M.brightness = require("bar.brightness")

-- ============================================================
-- Helper Functions
-- ============================================================

-- Creates a container with background, rounded corners and margins
function M.create_widget_container(widget, custom_opts)
    -- Default options
    local default_opts = {
        widget_spacing = beautiful.spacing,
        bg = beautiful.bg_normal,
        radius = 20,
        margin = {
            left = beautiful.spacing_lg,
            right = beautiful.spacing_lg,
            top = beautiful.spacing,
            bottom = beautiful.spacing
        }
    }
    
    -- Override defaults with custom options
    local opts = custom_opts and utils.merge_tables(default_opts, custom_opts) or default_opts
    
    -- Apply spacing if widget is a layout
    if type(widget) == "table" and widget.spacing ~= nil then
        widget.spacing = opts.widget_spacing
    end
    
    -- Create and return container
    return wibox.widget({
        {
            widget,
            left = opts.margin.left,
            right = opts.margin.right,
            top = opts.margin.top,
            bottom = opts.margin.bottom,
            widget = wibox.container.margin,
        },
        shape = utils.rounded_rect(opts.radius),
        bg = opts.bg,
        widget = wibox.container.background,
    })
end

-- Create a date widget with formatted date
function M.create_date_widget()
    return wibox.widget.textclock("%a %b %d %Y")
end

-- Create a clock widget with time only
function M.create_clock_widget()
    return wibox.widget.textclock("%H:%M")
end

-- Create system tray widget
function M.create_systray()
    return wibox.widget.systray()
end

-- Create a taglist widget for the screen
function M.create_taglist(s, buttons)
    return awful.widget.taglist({
        screen = s,
        buttons = buttons,
        filter = awful.widget.taglist.filter.all,
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = beautiful.spacing,
        },
        style = { shape = gears.shape.circle },
        widget_template = {
            {
                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left = beautiful.spacing,
                right = beautiful.spacing,
                widget = wibox.container.margin,
            },
            id = "background_role",
            widget = wibox.container.background,
        },
    })
end

-- Create a wibar
function M.create_wibar(s, widgets)
   print("Creating wibar for screen", s.index)
    -- Create wibar
    local wibar = awful.wibar({
        height = beautiful.bar_height,
        type = "dock",
        bg = "#00000000", -- Transparent background
        position = "top",
        screen = s,
    })
    
    -- Setup wibar layout
    wibar:setup({
        {
            layout = wibox.layout.stack,
            -- Bottom layer: Main wibar content
            {
                layout = wibox.layout.align.horizontal,
                -- Left widgets
                {
                    layout = wibox.layout.fixed.horizontal,
                    M.create_widget_container(widgets.taglist),
                },
                -- Middle widgets (empty)
                nil,
                -- Right widgets
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = beautiful.spacing,
                    M.create_widget_container(widgets.systray),
                    M.create_widget_container(widgets.status_widgets, { widget_spacing = beautiful.spacing_lg }),
                    M.create_widget_container(widgets.date),
                },
            },
            -- Top layer: Centered clock
            {
                M.create_widget_container(widgets.clock),
                valign = "center",
                halign = "center",
                layout = wibox.container.place,
            },
        },
        -- Add margins around entire wibar
        left = beautiful.useless_gap * 2,
        right = beautiful.useless_gap * 2,
        top = beautiful.useless_gap * 2,
        widget = wibox.container.margin,
    })
    
    return wibar
end

return M
