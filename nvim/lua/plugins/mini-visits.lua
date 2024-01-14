local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    v = { name = "+visits" },
  },
})

return {
  "echasnovski/mini.visits",
  event = "BufEnter",
  config = function()
    require("mini.visits").setup()

    local map_vis = function(keys, call, desc)
      local rhs = "<Cmd>lua MiniVisits." .. call .. "<CR>"
      vim.keymap.set("n", "<Leader>" .. keys, rhs, { desc = desc })
    end

    map_vis("vv", "add_label()", "Add label")
    map_vis("vV", "remove_label()", "Remove label")
    map_vis("vl", 'select_label("", "")', "Select label (all)")
    map_vis("vL", "select_label()", "Select label (cwd)")

    local make_select_path = function(select_global, recency_weight)
      local visits = require("mini.visits")
      local sort = visits.gen_sort.default({ recency_weight = recency_weight })
      local select_opts = { sort = sort }
      return function()
        local cwd = select_global and "" or vim.fn.getcwd()
        visits.select_path(cwd, select_opts)
      end
    end

    local map = function(lhs, desc, ...)
      vim.keymap.set("n", lhs, make_select_path(...), { desc = desc })
    end

    -- Adjust LHS and description to your liking
    map("<Leader>vr", "Select recent (all)", true, 1)
    map("<Leader>vR", "Select recent (cwd)", false, 1)
    map("<Leader>vy", "Select frecent (all)", true, 0.5)
    map("<Leader>vY", "Select frecent (cwd)", false, 0.5)
    map("<Leader>vf", "Select frequent (all)", true, 0)
    map("<Leader>vF", "Select frequent (cwd)", false, 0)
  end,
}
