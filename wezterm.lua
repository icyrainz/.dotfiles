local w = require("wezterm")

local config = {}

if w.config_builder then
	config = w.config_builder()
end

config.color_scheme = "Nord"
config.hide_tab_bar_if_only_one_tab = true

config.scrollback_lines = 10000

config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.font_size = 17.0

-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	-- reverse lookup
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = w.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.keys = {
	{
		key = "w",
		mods = "CMD|CTRL",
		action = w.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "-",
		mods = "CMD|CTRL",
		action = w.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "CMD|CTRL",
		action = w.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
}

return config
