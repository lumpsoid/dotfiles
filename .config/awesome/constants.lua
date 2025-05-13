local gfs = require("gears.filesystem")

local M = {}

M.terminal = "uxterm"
M.editor = "emacs"
M.editor_cmd = M.terminal .. " -e " .. M.editor
M.mods = {
	m = "Mod4",
	s = "Shift",
	c = "Control",
}
M.wallpapers = gfs.get_configuration_dir() .. "wallpapers/"

return M
