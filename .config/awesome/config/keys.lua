-- Keybindings: global, tag, layout and per-client.
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local constants = require("constants")
local bar = require("bar")

local modkey   = constants.mods.m
local terminal = constants.terminal
local ctl      = bar.controllers

-- ── Minimal right-click desktop menu ─────────────────────────────
local main_menu = awful.menu({
  items = {
    { "terminal", terminal },
    { "hotkeys",  function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "restart",  awesome.restart },
    { "quit",     function() awesome.quit() end },
  },
})

-- ── Mouse on the desktop ─────────────────────────────────────────
awful.mouse.append_global_mousebindings({
  awful.button({}, 3, function() main_menu:toggle() end),
  awful.button({}, 4, awful.tag.viewprev),
  awful.button({}, 5, awful.tag.viewnext),
})

-- ── Media & hardware keys (wired to bar controllers) ─────────────
awful.keyboard.append_global_keybindings({
  awful.key({}, "XF86AudioRaiseVolume", function() ctl.volume.increase() end,
    { description = "increase volume", group = "media" }),
  awful.key({}, "XF86AudioLowerVolume", function() ctl.volume.decrease() end,
    { description = "decrease volume", group = "media" }),
  awful.key({}, "XF86AudioMute", function() ctl.volume.toggle() end,
    { description = "toggle mute", group = "media" }),
  awful.key({}, "XF86AudioMicMute",
    function() awful.spawn.with_shell("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") end,
    { description = "toggle mic mute", group = "media" }),
  awful.key({}, "XF86MonBrightnessUp", function() ctl.brightness.increase() end,
    { description = "increase brightness", group = "media" }),
  awful.key({}, "XF86MonBrightnessDown", function() ctl.brightness.decrease() end,
    { description = "decrease brightness", group = "media" }),
  awful.key({}, "Print", function() awful.spawn(os.getenv("HOME") .. "/.local/bin/sc-printscreen") end,
    { description = "screenshot", group = "media" }),
})

-- ── Awesome & launchers ──────────────────────────────────────────
awful.keyboard.append_global_keybindings({
  awful.key({ modkey }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", awesome.quit,
    { description = "quit awesome", group = "awesome" }),
  awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey }, "w", function() awful.spawn("librewolf") end,
    { description = "open browser", group = "launcher" }),
  awful.key({ modkey }, "d", function() awful.spawn.with_shell("dmenu_run") end,
    { description = "run dmenu", group = "launcher" }),
  awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
    { description = "run prompt", group = "launcher" }),
  awful.key({ modkey }, "p", function() require("menubar").show() end,
    { description = "show the menubar", group = "launcher" }),
})

-- ── Tags ─────────────────────────────────────────────────────────
awful.keyboard.append_global_keybindings({
  awful.key({ modkey }, "Left", awful.tag.viewprev,
    { description = "view previous", group = "tag" }),
  awful.key({ modkey }, "Right", awful.tag.viewnext,
    { description = "view next", group = "tag" }),
  awful.key({ modkey }, "Escape", awful.tag.history.restore,
    { description = "go back", group = "tag" }),
  awful.key({
    modifiers = { modkey }, keygroup = "numrow",
    description = "view tag", group = "tag",
    on_press = function(i)
      local t = awful.screen.focused().tags[i]
      if t then t:view_only() end
    end,
  }),
  awful.key({
    modifiers = { modkey, "Control" }, keygroup = "numrow",
    description = "toggle tag", group = "tag",
    on_press = function(i)
      local t = awful.screen.focused().tags[i]
      if t then awful.tag.viewtoggle(t) end
    end,
  }),
  awful.key({
    modifiers = { modkey, "Shift" }, keygroup = "numrow",
    description = "move client to tag", group = "tag",
    on_press = function(i)
      if client.focus then
        local t = client.focus.screen.tags[i]
        if t then client.focus:move_to_tag(t) end
      end
    end,
  }),
})

-- ── Focus & layout ───────────────────────────────────────────────
awful.keyboard.append_global_keybindings({
  awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
    { description = "focus next", group = "client" }),
  awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
    { description = "focus previous", group = "client" }),
  awful.key({ modkey }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then client.focus:raise() end
  end, { description = "last focused", group = "client" }),
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    { description = "swap with next", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
    { description = "focus next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
    { description = "focus previous screen", group = "screen" }),
  awful.key({ modkey }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),

  awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end,
    { description = "grow master", group = "layout" }),
  awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "shrink master", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "more master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "fewer master clients", group = "layout" }),
  awful.key({ modkey }, "space", function() awful.layout.inc(1) end,
    { description = "next layout", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
    { description = "previous layout", group = "layout" }),
})

-- ── Per-client ───────────────────────────────────────────────────
client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    awful.button({}, 1, function(c) c:activate({ context = "mouse_click" }) end),
    awful.button({ modkey }, 1, function(c) c:activate({ context = "mouse_click", action = "mouse_move" }) end),
    awful.button({ modkey }, 3, function(c) c:activate({ context = "mouse_click", action = "mouse_resize" }) end),
  })
end)

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    awful.key({ modkey }, "q", function(c) c:kill() end,
      { description = "close", group = "client" }),
    awful.key({ modkey }, "f", function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end, { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
      { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Shift" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
      { description = "move to master", group = "client" }),
    awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
      { description = "move to screen", group = "client" }),
    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
      { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey }, "n", function(c) c.minimized = true end,
      { description = "minimize", group = "client" }),
    awful.key({ modkey, "Control" }, "n", function()
      local c = awful.client.restore()
      if c then c:activate({ raise = true, context = "key.unminimize" }) end
    end, { description = "restore minimized", group = "client" }),
    awful.key({ modkey }, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
    end, { description = "(un)maximize", group = "client" }),
  })
end)

return { main_menu = main_menu }
