-- Applications to spawn once, on login. Add your own below.
local awful = require("awful")

local function run_once(cmd)
  awful.spawn.with_shell(
    string.format("pgrep -fx '%s' >/dev/null || (%s &)", cmd, cmd)
  )
end

local autostart = {
  -- "picom",
  -- "nm-applet",
}

for _, cmd in ipairs(autostart) do
  run_once(cmd)
end
