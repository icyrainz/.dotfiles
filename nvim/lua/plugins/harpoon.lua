return {
  "ThePrimeagen/harpoon",
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

			local function opts(desc)
				return { desc = "[harpoon] " .. desc }
			end

    vim.keymap.set("n", "<leader>ha", function() mark.add_file() end, opts("add file"))
    vim.keymap.set("n", "<leader>h", function() ui.toggle_quick_menu() end, opts("list files"))
    vim.keymap.set("n", "<leader>hn", function() ui.nav_next() end, opts("nav next"))
    vim.keymap.set("n", "<leader>hp", function() ui.nav_prev() end, opts("nav prev"))
    vim.keymap.set("n", "<leader>h1", function() ui.nav_file(1) end, opts("nav file 1"))
    vim.keymap.set("n", "<leader>h2", function() ui.nav_file(2) end, opts("nav file 2"))
    vim.keymap.set("n", "<leader>h3", function() ui.nav_file(3) end, opts("nav file 3"))
    vim.keymap.set("n", "<leader>h4", function() ui.nav_file(4) end, opts("nav file 4"))
    vim.keymap.set("n", "<leader>h5", function() ui.nav_file(5) end, opts("nav file 5"))
  end,
}
