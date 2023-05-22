return {
	"mizlan/iswap.nvim",
  config = function ()
    require('iswap').setup({
      move_cursor = true,
      flash_style = false,
      autoswap = true,
    })

    vim.keymap.set("n", "<leader>[", ":ISwapWithLeft<CR>", { silent = true, desc = "Swap left" })
    vim.keymap.set("n", "<leader>]", ":ISwapWithRight<CR>", { silent = true, desc = "Swap right" })
  end
}
