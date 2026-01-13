return {
  "monaqa/dial.nvim",
  opts = function(_, opts)
    local augend = require("dial.augend")
    vim.list_extend(opts.groups.typescript, {
      augend.user.new({
        find = function(line, _)
          local s, e = vim.regex([[\v^\s*\zsit(.only)?]]):match_str(line)
          if s ~= nil then
            return { from = s + 1, to = e }
          end
        end,
        add = function(text, _, _)
          if text == "it" then
            text = "it.only"
          else
            text = "it"
          end
          return { text = text }
        end,
      }),
    })

    opts.groups.zig = {
      augend.constant.new({ elements = { "var", "const" } }),
    }

    opts.dials_by_ft.zig = "zig"
  end,
}
