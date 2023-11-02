return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    cmd = { "Telescope" },
    keys = {
      {
        "<leader>ff",
        function() require("telescope.builtin").find_files() end,
        desc = "[Telescope] files",
      },
      {
        "<leader>fa",
        "<CMD>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
        desc = "[Telescope] files (all)",
      },
      {
        "<leader>fe",
        function() require("telescope.builtin").live_grep({ cwd = require("telescope.utils").buffer_dir() }) end,
        desc = "[Telescope] live grep current dir",
      },
      {
        "<leader>fE1",
        function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h") }) end,
        desc = "[Telescope] live grep 1",
      },
      {
        "<leader>fE2",
        function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h:h") }) end,
        desc = "[Telescope] live grep 2",
      },
      {
        "<leader>fE3",
        function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h:h:h") }) end,
        desc = "[Telescope] live grep 3",
      },
      {
        "<leader>fg",
        "<CMD>Telescope live_grep<CR>",
        desc = "[Telescope] live grep",
      },
      {
        "<leader>fw",
        function() require("telescope.builtin").grep_string() end,
        desc = "[Telescope] grep word",
      },
      {
        "<leader>fW",
        function() require("telescope.builtin").grep_string({ cwd = require("telescope.utils").buffer_dir() }) end,
        desc = "[Telescope] grep word",
      },
      {
        "<leader>fs",
        function() require('telescope.builtin').grep_string({ search = vim.fn.input("Search term: ") }) end,
        desc = "[Telescope] grep string",
      },
      {
        "<leader>fb",
        function() require('telescope.builtin').buffers() end,
        desc = "[Telescope] buffers",
      },
      {
        "<leader>fn",
        "<CMD>Telescope noice<CR>",
        desc = "[Telescope] noice",
      },
      {
        "<leader>fhl",
        "<CMD>Telescope highlights<CR>",
        desc = "[Telescope] highlights",
      },
      {
        "<leader>fo",
        function()
          return require("telescope.builtin").oldfiles({
            only_cwd = true,
          })
        end,
        desc = "[Telescope] oldfiles",
      },
      {
        "<leader>fr",
        function() require("telescope.builtin").registers() end,
        desc = "[Telescope] registers",
      },
      -- {
      --   "<leader>flw",
      --   function() require("telescope.builtin").lsp_workspace_symbols() end,
      --   desc = "[Telescope] lsp workspace symbols",
      -- },
      {
        "<leader>fl",
        function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,
        desc = "[Telescope] lsp dynamic workspace symbols",
      },
      {
        "<leader>fm",
        function() require("telescope.builtin").marks() end,
        desc = "[Telescope] marks",
      },
      {
        "<leader>f'",
        function() require("telescope.builtin").resume() end,
        desc = "[Telescope] resume",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local layout = require("telescope.actions.layout")

      telescope.setup({
        defaults = {
          file_ignore_patterns = require('utils').file_ignore_patterns,
          mappings = {
            i = {
              ["<F3>"] = layout.cycle_layout_next,
              ["<F4>"] = layout.toggle_preview,
              ["<C-s>"] = actions.file_split,
            }
          }
        },
        pickers = {
          live_grep = {
            mappings = {
              i = {
                ["<c-o>"] = actions.to_fuzzy_refine,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          }
        }
      })
      require("telescope").load_extension("noice")
      require('telescope').load_extension('fzf')
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    lazy = true,
    build = "make",
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>fj",
        "<CMD>Telescope live_grep_args<CR>",
        desc = "[Telescope] live grep with args",
      }
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

      telescope.setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
          },
        },
      })
      telescope.load_extension("live_grep_args")
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>fp",
        "<CMD>Telescope file_browser<CR>",
        desc = "[Telescope] file browser",
      }
    },
    config = function()
      require("telescope").load_extension("file_browser")
    end
  },
}
