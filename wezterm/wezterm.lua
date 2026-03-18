local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.max_fps = 120
config.animation_fps = 120
-- Use local fonts dir to skip slow system font scanning (9s → 0.1s)
-- Run: ln -s ~/Library/Fonts/{Iosevka.ttc,SymbolsNerdFontMono-Regular.ttf} ~/.config/wezterm/fonts/
local fonts_dir = wezterm.config_dir .. "/fonts"
local f = io.open(fonts_dir, "r")
if f then
	f:close()
	config.font_dirs = { "fonts" }
	config.font_locator = "ConfigDirsOnly"
end

-- Machine-specific overrides via wezterm.local.lua
local ok, local_config = pcall(dofile, wezterm.config_dir .. "/wezterm.local.lua")
if ok and type(local_config) == "function" then
	local_config(config, wezterm)
end

config.color_scheme = "tokyonight_night"

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.scrollback_lines = 1000000

local custom_bg, bg = pcall(require, "bg")
if custom_bg then
	config.window_background_opacity = bg.window_background_opacity
	config.window_background_image = bg.bg_file
else
	config.window_background_opacity = 0.9
end

config.macos_window_background_blur = 20

config.window_decorations = "RESIZE"

config.native_macos_fullscreen_mode = true

config.use_fancy_tab_bar = false

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

local function is_inside_vim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

local function is_outside_vim(pane)
	return not is_inside_vim(pane)
end

local function bind_if(cond, key, mods, action)
	local function callback(win, pane)
		if _G.tmux_navigation_enabled then
			win:perform_action(act.SendKey({ key = key, mods = mods }), pane)
			return
		end
		if cond(pane) then
			win:perform_action(action, pane)
		else
			win:perform_action(act.SendKey({ key = key, mods = mods }), pane)
		end
	end

	return { key = key, mods = mods, action = wezterm.action_callback(callback) }
end

_G.tmux_navigation_enabled = true

local function toggle_tmux_navigation(window)
	_G.tmux_navigation_enabled = not _G.tmux_navigation_enabled

	local message
	if _G.tmux_navigation_enabled then
		message = "Tmux navigation enabled"
	else
		message = "Tmux navigation disabled"
	end

	window:toast_notification("Wezterm", message, nil, 4000)
end

-- config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "Escape",
		mods = "CMD",
		action = act.ActivateWindowRelative(1),
	},
	-- { key = 'Enter', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
	{
		key = "m",
		mods = "CMD|CTRL",
		action = act.TogglePaneZoomState,
	},
	{
		key = "w",
		mods = "CMD|CTRL",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "-",
		mods = "CMD|CTRL",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "CMD|CTRL",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "RightArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "UpArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "DownArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = ",",
		mods = "CMD",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	bind_if(is_outside_vim, "h", "CTRL", act.ActivatePaneDirection("Left")),
	bind_if(is_outside_vim, "l", "CTRL", act.ActivatePaneDirection("Right")),
	bind_if(is_outside_vim, "j", "CTRL", act.ActivatePaneDirection("Down")),
	bind_if(is_outside_vim, "k", "CTRL", act.ActivatePaneDirection("Up")),
	{
		key = "<",
		mods = "CMD",
		action = act.MoveTabRelative(-1),
	},
	{
		key = ">",
		mods = "CMD",
		action = act.MoveTabRelative(1),
	},
	{
		key = "d",
		mods = "CMD",
		action = act.ScrollByPage(0.5),
	},
	{
		key = "u",
		mods = "CMD",
		action = act.ScrollByPage(-0.5),
	},
	{
		key = "b",
		mods = "CMD",
		action = act.ScrollToBottom,
	},
	{
		key = "=",
		mods = "CMD|CTRL",
		action = wezterm.action_callback(function(window, pane)
			toggle_tmux_navigation(window)
		end),
	},
	{
		key = "e",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			if not overrides.window_background_opacity then
				overrides.window_background_opacity = 1
				overrides.window_background_image = ""
			else
				overrides = nil
			end
			window:set_config_overrides(overrides)
		end),
	},
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}

config.window_padding = {
	bottom = 0,
	top = 0,
	left = 0,
	right = 0,
}

return config
