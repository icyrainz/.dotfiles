return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            }
          }
        }
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          TelescopeTitle = { fg = theme.ui.special, bold = true },
          TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
          TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
          TelescopePreviewNormal = { bg = theme.ui.bg_dim },
          TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },

          TreesitterContext = { bg = theme.ui.bg_p1 },
          TreesitterContextLineNumber = { bg = theme.ui.bg_p1 },
          TreesitterContextBottom = { bg = theme.ui.bg_p1 },

          InclineNormal = { bg = theme.ui.bg_p1 },
          InclineNormalNC = { bg = theme.ui.bg_p1 },
        }
      end,
    }
  },
  -- {
  -- 	"Mofiqul/dracula.nvim",
  -- 	config = function()
  -- 		vim.cmd.colorscheme("dracula")
  -- 	end,
  -- },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      }
    }
  },
  -- { "catppuccin/nvim", name = "catppuccin" },
  -- {
  -- 	"Alexis12119/nightly.nvim",
  -- 	opts = function()
  -- 		return {
  -- 			transparent = true,
  -- 		}
  -- 	end,
  -- },
  -- {
  -- 	"sainnhe/gruvbox-material",
  -- 	config = function()
  -- 		vim.g.gruvbox_material_background = "hard"
  -- 		vim.g.gruvbox_material_foreground = "mix"
  -- 		vim.g.gruvbox_material_better_performance = 1
  --
  -- 		vim.cmd.colorscheme("gruvbox-material")
  -- 	end,
  -- },
}
