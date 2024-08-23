local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"

config.font = wezterm.font({ family = "Berkeley Mono" })
-- config.font = wezterm.font({ family = "Hasklug Nerd Font" })

config.font_size = 14.0

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }

-- native fullscreen is SOOOO slow (the animation kills me)
config.native_macos_fullscreen_mode = false

-- use this along with Ctrl-Shift-L to see the debug messages for what actual keycodes were detected
--config.debug_key_events = true


config.keys = {}
for i = 1, 9 do
	-- {
	-- 	key = "1",
	-- 	mods = "CMD",
	-- 	action = wezterm.action({ SendKey = { key = "F1" } }),
	-- },
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CMD",
		action = wezterm.action({ SendKey = { key = "F" .. i } }),
	})
end

config.initial_rows = 90
config.initial_cols = 300

config.audible_bell = "Disabled"

return config
