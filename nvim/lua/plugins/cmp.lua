return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    for _, item in ipairs(opts.sources) do
      if item.name == "buffer" then
        item.keyword_length = 4
        break
      end
    end
  end,
}
