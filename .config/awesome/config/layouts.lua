-- A deliberately small set of layouts. Master-stack first.
local awful = require("awful")

tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.tile,        -- master + stack (default)
    awful.layout.suit.tile.bottom, -- master on top, stack below
    awful.layout.suit.max,         -- fullscreen stack
    awful.layout.suit.floating,    -- free placement
  })
end)
