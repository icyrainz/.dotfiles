local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- config.color_scheme = "Tokyo Night Storm (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

config.scrollback_lines = 1000000

config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.font_size = 17.0

config.window_decorations = "RESIZE"

config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}

config.mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

local function is_inside_vim(pane)
  local tty = pane:get_tty_name()
  if tty == nil then return false end

  local success, stdout, stderr = wezterm.run_child_process
      { 'sh', '-c',
        'ps -o state= -o comm= -t' .. wezterm.shell_quote_arg(tty) .. ' | ' ..
        'grep -iqE \'^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$\'' }

  return success
end

local function is_outside_vim(pane) return not is_inside_vim(pane) end

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

_G.tmux_navigation_enabled = false

local function toggle_tmux_navigation(window)
  _G.tmux_navigation_enabled = not _G.tmux_navigation_enabled

  local message;
  if _G.tmux_navigation_enabled then
    message = 'Tmux navigation enabled'
  else
    message = 'Tmux navigation disabled'
  end

  window:toast_notification('Wezterm', message, nil, 4000)
end

-- config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = 'Escape',
    mods = 'CMD',
    action = act.ActivateWindowRelative(1),
  },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
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
  -- bind_if(
  --   is_outside_vim,
  --   'h',
  --   'CTRL',
  --   act.ActivatePaneDirection('Left')
  -- ),
  -- bind_if(
  --   is_outside_vim,
  --   'l',
  --   'CTRL',
  --   act.ActivatePaneDirection('Right')
  -- ),
  -- bind_if(
  --   is_outside_vim,
  --   'j',
  --   'CTRL',
  --   act.ActivatePaneDirection('Down')
  -- ),
  -- bind_if(
  --   is_outside_vim,
  --   'k',
  --   'CTRL',
  --   act.ActivatePaneDirection('Up')
  -- ),
  {
    key = "]",
    mods = "CMD|CTRL",
    action = act.ScrollByPage(0.5),
  },
  {
    key = "[",
    mods = "CMD|CTRL",
    action = act.ScrollByPage(-0.5),
  },
  {
    key = "B",
    mods = "CMD|CTRL",
    action = act.ScrollToBottom,
  },
  {
    key = "=",
    mods = "CMD|CTRL",
    action = wezterm.action_callback(function(window, pane)
      toggle_tmux_navigation(window)
    end),
  },
}

-- -- Configure default multiplexer ssh domain
-- config.ssh_domains = {
--   {
--     name = 'localhost',
--     remote_address = 'localhost',
--   },
-- }
-- config.default_gui_startup_args = {
--   'connect',
--   'localhost'
-- }

return config
