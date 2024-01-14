return {
  {
    "kevinhwang91/nvim-bqf",
    dependencies = {
      "junegunn/fzf",
      config = function()
        vim.fn["fzf#install"]()
      end,
    },
    ft = "qf",
    opts = {
      auto_resize_height = true,
      preview = {
        auto_preview = false,
      },
      filter = {
        fzf = {
          extra_opts = {
            description = "Extra options for fzf",
            default = { "--bind", "ctrl-o:toggle-all,ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up" },
          },
        },
      },
    },
  },
}
