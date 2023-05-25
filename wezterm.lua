local wezterm = require('wezterm')

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- config.color_scheme = 'AdventureTime'
-- config.hide_tab_bar_if_only_one_tab = true

config.window_background_opacity = 0.8
config.macos_window_background_blur = 20

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

return config
