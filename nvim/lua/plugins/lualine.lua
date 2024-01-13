return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.extensions, "nvim-dap-ui")
  end,
}
