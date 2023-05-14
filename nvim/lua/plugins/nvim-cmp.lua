return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    { 'L3MON4D3/LuaSnip' },
  },
  config = function()
    require('lsp-zero.cmp').extend()

    local cmp = require('cmp')
    local cmp_action = require('lsp-zero').cmp_action()

    cmp.setup({
      sources = {
        { name = 'copilot' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'luasnip', keuword_length = 2 },
      },
      window = {
        documentation = cmp.config.window.bordered(),
      },
      formatting = {
        fields = { "menu", "abbr", "kind" },

        format = function(entry, item)
          local menu_icon = {
            copilot = "",
            nvim_lsp = "λ",
            luasnip = "⋗",
            path = "🖫",
            nvim_lua = "Π",
          }

          item.menu = menu_icon[entry.source.name]
          return item
        end,
      },
      mapping = {
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        ["<Tab>"] = cmp_action.luasnip_supertab(),
        ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
        ['<C-e>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false
        }),
      }
    })
  end
}
