return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    for _, item in ipairs(opts.sources) do
      if item.name == "buffer" then
        item.keyword_length = 4
        break
      end
    end

    -- local cmp = require("cmp")
    -- opts.mapping = cmp.mapping.preset.insert({
    --   ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    --   ["<C-f>"] = cmp.mapping.scroll_docs(4),
    --   ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    --   ["<S-CR>"] = cmp.mapping.confirm({
    --     behavior = cmp.ConfirmBehavior.Replace,
    --     select = true,
    --   }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    --   ["<C-CR>"] = function(fallback)
    --     cmp.abort()
    --     fallback()
    --   end,
    -- })
  end,
}
