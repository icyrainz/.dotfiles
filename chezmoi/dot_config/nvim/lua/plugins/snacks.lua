return {
  {
    "snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          { section = "terminal", cmd = "fortune -s | cowsay", hl = "header", padding = 1, indent = 8 },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          {
            icon = " ",
            title = "Recent Files",
            section = "recent_files",
            cwd = true,
            limit = 10,
            indent = 2,
            padding = 1,
          },
          -- { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
      scroll = { enabled = false },
    },
  },
}
