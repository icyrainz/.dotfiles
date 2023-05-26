local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Nord"
config.hide_tab_bar_if_only_one_tab = true

config.scrollback_lines = 10000

config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.font_size = 17.0

-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.keys = {
	{
		key = "w",
		mods = "CMD|CTRL",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "-",
		mods = "CMD|CTRL",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "CMD|CTRL",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "CMD|CTRL",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "RightArrow",
		mods = "CMD|CTRL",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "UpArrow",
		mods = "CMD|CTRL",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "DownArrow",
		mods = "CMD|CTRL",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
}

return config
