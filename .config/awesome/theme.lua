-- Refined Kanagawa theme — minimal, flat, comfortable.
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

-- ── Kanagawa palette ─────────────────────────────────────────────
local kanagawa = {
  sumiInk0   = "#16161D",
  sumiInk1   = "#1F1F28", -- background
  sumiInk2   = "#2A2A37",
  sumiInk3   = "#363646", -- inactive border / muted surface
  sumiInk4   = "#54546D", -- muted
  fujiWhite  = "#DCD7BA", -- foreground
  oldWhite   = "#C8C093",
  fujiGray   = "#727169", -- disabled / empty
  crystalBlue = "#7E9CD8", -- accent
  springBlue = "#7FB4CA",
  waveAqua   = "#6A9589",
  springGreen = "#98BB6C",
  autumnGreen = "#76946A",
  samuraiRed = "#E82424",
  peachRed   = "#FF5D62",
  autumnRed  = "#C34043",
  carpYellow = "#E6C384",
  autumnYellow = "#DCA561",
  oniViolet  = "#957FB8",
  sakuraPink = "#D27E99",
  surimiOrange = "#FFA066",
}
theme.kanagawa = kanagawa

-- ── Named roles ──────────────────────────────────────────────────
theme.transparent = "#00000000"
theme.accent  = kanagawa.crystalBlue
theme.muted   = kanagawa.sumiInk4
theme.surface = kanagawa.sumiInk2

-- ── Font ─────────────────────────────────────────────────────────
-- Cascadia Mono NF ships Nerd Font glyphs, so bar icons resolve.
theme.font      = "Cascadia Mono NF 11"
theme.font_bold = "Cascadia Mono NF Bold 11"

-- ── Base colours ─────────────────────────────────────────────────
theme.bg_normal   = kanagawa.sumiInk1
theme.bg_focus    = kanagawa.sumiInk2
theme.bg_urgent   = kanagawa.autumnRed
theme.bg_minimize = kanagawa.sumiInk0
theme.bg_systray  = kanagawa.sumiInk1

theme.fg_normal   = kanagawa.fujiWhite
theme.fg_focus    = kanagawa.crystalBlue
theme.fg_urgent   = kanagawa.fujiWhite
theme.fg_minimize = kanagawa.fujiGray

-- ── Spacing scale ────────────────────────────────────────────────
theme.spacing    = dpi(6)
theme.spacing_md = dpi(10)
theme.spacing_lg = dpi(16)

-- ── Gaps & borders (comfortable, restrained) ─────────────────────
theme.useless_gap    = dpi(6)
theme.gap_single_client = true
theme.border_width   = dpi(2)
theme.border_radius  = dpi(6)
theme.border_focus   = kanagawa.crystalBlue
theme.border_normal  = kanagawa.sumiInk3
theme.border_marked  = kanagawa.sakuraPink

-- ── Bar ──────────────────────────────────────────────────────────
theme.bar_height   = dpi(26)
theme.bar_bg       = kanagawa.sumiInk1
theme.icon_size    = dpi(18)

-- ── Taglist (flat, minimal) ──────────────────────────────────────
theme.taglist_bg_focus      = theme.transparent
theme.taglist_fg_focus      = kanagawa.crystalBlue
theme.taglist_bg_occupied   = theme.transparent
theme.taglist_fg_occupied   = kanagawa.fujiWhite
theme.taglist_bg_empty      = theme.transparent
theme.taglist_fg_empty      = kanagawa.fujiGray
theme.taglist_bg_urgent     = theme.transparent
theme.taglist_fg_urgent     = kanagawa.peachRed
theme.taglist_spacing       = dpi(2)

-- ── System tray ──────────────────────────────────────────────────
theme.systray_icon_spacing = theme.spacing

-- ── Widget colours ───────────────────────────────────────────────
theme.battery_happy    = kanagawa.fujiWhite
theme.battery_tired    = kanagawa.autumnYellow
theme.battery_sad      = kanagawa.peachRed
theme.battery_charging = kanagawa.springGreen

-- ── Notifications ────────────────────────────────────────────────
theme.notification_bg           = kanagawa.sumiInk2
theme.notification_fg           = kanagawa.fujiWhite
theme.notification_border_color = kanagawa.sumiInk4
theme.notification_border_width = dpi(1)
theme.notification_margin       = dpi(12)
theme.notification_spacing      = dpi(8)

-- ── Hotkeys popup ────────────────────────────────────────────────
theme.hotkeys_bg          = kanagawa.sumiInk1
theme.hotkeys_fg          = kanagawa.fujiWhite
theme.hotkeys_modifiers_fg = kanagawa.fujiGray
theme.hotkeys_border_color = kanagawa.sumiInk4

return theme
