return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local utils = require("telescope.utils")
      local actions = require("telescope.actions")
      local layout = require("telescope.actions.layout")

      local function opts(desc)
        return { desc = "[Telescope] " .. desc }
      end

      vim.keymap.set("n", "<leader>ff", builtin.find_files, opts("files"))
      vim.keymap.set(
        "n",
        "<leader>fa",
        "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
        opts("files (all)")
      )
      vim.keymap.set("n", "<leader>fe", function()
        builtin.live_grep({ cwd = utils.buffer_dir() })
      end, opts("files in same dir"))
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts("live grep"))
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, opts("grep word"))
      vim.keymap.set("n", "<leader>fs", function()
        require('telescope.builtin').grep_string({ search = vim.fn.input("Search term: ") })
      end, opts("Grep string"))
      vim.keymap.set("n", "<leader>fb", builtin.buffers, opts("buffers"))
      vim.keymap.set("n", "<leader>fht", builtin.help_tags, opts("help tags"))
      vim.keymap.set("n", "<leader>fhl", builtin.highlights, opts("highlights"))
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, opts("oldfiles"))
      vim.keymap.set("n", "<leader>fr", builtin.registers, opts("registers"))
      vim.keymap.set("n", "<leader>fls", builtin.lsp_workspace_symbols, opts("lsp workspace symbols"))
      vim.keymap.set("n", "<leader>fld", builtin.lsp_dynamic_workspace_symbols, opts("lsp dynamic workspace symbols"))

      vim.keymap.set("n", "<leader>fm", builtin.resume, opts("resume"))

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
      })
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    build = "make",
    config = function()
      require('telescope').setup {
        extensions = {
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          }
        }
      }
      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require('telescope').load_extension('fzf')
    end,
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
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

      vim.keymap.set("n", "<leader>fj", "<cmd>Telescope live_grep_args<CR>", { desc = "[Telescope] live grep with args" })
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("file_browser")
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope file_browser<CR>", { desc = "[Telescope] file browser" })
    end
  },
}
