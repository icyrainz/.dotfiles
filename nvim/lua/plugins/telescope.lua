return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      local utils = require("telescope.utils")

      local function opts(desc)
        return { desc = "Telescope " .. desc }
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
      end, opts("Find files in same dir"))
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep_args<CR>", opts("live grep"))
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, opts("grep word"))
      -- vim.keymap.set("n", "<leader>fS", function()
      --      require ('telescope.builtin').grep_string({search = vim.fn.input("Search term: ")})
      -- end, opts("Grep string"))
      vim.keymap.set("n", "<leader>fb", builtin.buffers, opts("buffers"))
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts("help tags"))
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, opts("oldfiles"))

      vim.keymap.set("n", "<leader>fr", builtin.resume, opts("resume"))

      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "Session.vim",
            "kitty.conf",
            ".lock",
            ".md",
            "zsh/completions",
          },
        },
      })
    end,
  },
  -- {
  -- 	"nvim-telescope/telescope-project.nvim",
  -- 	config = function()
  -- 		require("telescope").load_extension("project")
  --
  -- 		-- vim.keymap.set("n", "<leader>fp", function()
  -- 		-- 	require("telescope").extensions.project.project()
  -- 		-- end, { desc = "Projects" })
  -- 	end,
  -- },
  --
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
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
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("file_browser")
    end
  },
}
