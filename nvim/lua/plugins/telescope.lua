local wk = require("which-key")
wk.add({
  { "<leader>set", group = "live_grep" },
})

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        config = function()
          local telescope = require("telescope")
          local actions = require("telescope.actions")
          local lga_actions = require("telescope-live-grep-args.actions")

          telescope.setup({
            extensions = {
              live_grep_args = {
                auto_quoting = true,
                mappings = {
                  i = {
                    ["<C-k>"] = lga_actions.quote_prompt(),
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                    ["<C-o>"] = actions.to_fuzzy_refine,
                  },
                },
              },
            },
          })
          telescope.load_extension("live_grep_args")
        end,
      },
    },
    opts = {
      pickers = {
        live_grep = {
          mappings = {
            i = {
              ["<c-o>"] = require("telescope.actions").to_fuzzy_refine,
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>,",
        false,
      },
      {
        "<leader>see",
      -- stylua: ignore
        function() require("telescope.builtin").live_grep({ cwd = require("telescope.utils").buffer_dir() }) end,
        desc = "Live grep current dir",
      },
      {
        "<leader>se1",
      -- stylua: ignore
        function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h") }) end,
        desc = "Live grep 1",
      },
      {
        "<leader>se2",
      -- stylua: ignore
        function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h:h") }) end,
        desc = "Live grep 2",
      },
      {
        "<leader>se3",
      -- stylua: ignore
        function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h:h:h") }) end,
        desc = "Live grep 3",
      },
      {
        "<leader>sE",
        "<CMD>Telescope live_grep_args<CR>",
        desc = "Live grep with args",
      },
      { "<leader>s'", "<cmd>Telescope resume<cr>", desc = "Resume" },
    },
  },
}
