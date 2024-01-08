return {
  {
    "tpope/vim-fugitive",
    cmd = "G",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
    keys = {
      { "<leader>gn",  "<CMD>lua require('gitsigns').next_hunk()<CR>",          desc = "Git next hunk" },
      { "<leader>gp",  "<CMD>lua require('gitsigns').preview_hunk()<CR>",       desc = "Git preview hunk" },
      { "<leader>gr",  "<CMD>lua require('gitsigns').reset_hunk()<CR>",         desc = "Git reset hunk" },
      { "<leader>gR",  "<CMD>lua require('gitsigns').reset_buffer()<CR>",       desc = "Git reset buffer" },
      { "<leader>gs",  "<CMD>lua require('gitsigns').stage_hunk()<CR>",         desc = "Git stage hunk" },
      { "<leader>gS",  "<CMD>lua require('gitsigns').stage_buffer()<CR>",       desc = "Git stage buffer" },
      { "<leader>gu",  "<CMD>lua require('gitsigns').undo_stage_hunk()<CR>",    desc = "Git undo stage hunk" },
      { "<leader>gU",  "<CMD>lua require('gitsigns').reset_buffer_index()<CR>", desc = "Git reset buffer index" },
      { "<leader>gv",  "<CMD>lua require('gitsigns').select_hunk()<CR>",        desc = "Git select hunk" },
      { "<leader>gB",  "<CMD>lua require('gitsigns').blame_line()<CR>",         desc = "Git blame line" },
      { "<leader>gtd", "<CMD>lua require('gitsigns').toggle_deleted()<CR>",     desc = "Toggle git deleted" },
      { "<leader>gtw", "<CMD>lua require('gitsigns').toggle_word_diff()<CR>",   desc = "Toggle git word diff" },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    other = "VeryLazy",
    config = true,
  },
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      {
        "<leader>gwa",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Git worktree add",
      },
      {
        "<leader>gww",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Git worktrees",
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.load_extension("git_worktree")
    end,
  },
  {
    "f-person/git-blame.nvim",
    keys = {
      { "<leader>gbf", "<CMD>GitBlameCopyFileURL<CR>",   desc = "Git blame copy file URL" },
      { "<leader>gbc", "<CMD>GitBlameCopyCommitURL<CR>", desc = "Git blame copy commit URL" },
    },
    init = function()
      vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
      vim.g.gitblame_date_format = "%x %X"
    end,
  },
}
