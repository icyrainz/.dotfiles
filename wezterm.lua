local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- config.color_scheme = "Tokyo Night Storm (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

config.scrollback_lines = 10000

config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.font_size = 17.0

-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

config.keys = {
  {
    key = 'm',
    mods = 'CMD|CTRL',
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
    key = ',',
    mods = 'CMD|CTRL',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
}

return config
