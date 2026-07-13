-- Client rules. Titlebars stay off for a clean, minimal look.
local awful = require("awful")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
  -- Defaults for every client.
  ruled.client.append_rule({
    id         = "global",
    rule       = {},
    properties = {
      focus     = awful.client.focus.filter,
      raise     = true,
      screen    = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  })

  -- Dialogs and utilities that behave better floating and centered.
  ruled.client.append_rule({
    id       = "floating",
    rule_any = {
      instance = { "copyq", "pinentry" },
      class    = {
        "Arandr", "Blueman-manager", "Gpick", "Kruler",
        "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
        "Pavucontrol", "Nm-connection-editor",
      },
      name = { "Event Tester" },
      role = { "AlarmWindow", "ConfigManager", "pop-up" },
    },
    properties = {
      floating  = true,
      placement = awful.placement.centered,
    },
  })

  -- No titlebars anywhere.
  ruled.client.append_rule({
    id         = "titlebars",
    rule_any   = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = false },
  })
end)
