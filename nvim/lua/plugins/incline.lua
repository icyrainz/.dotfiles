return {
	"b0o/incline.nvim",
	opts = {
		render = function(props)
			local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":.")
			local color = vim.api.nvim_buf_get_option(props.buf, "modified") and "orange" or "gray"

			local buffer = {
				{ filename, gui = "bold", guifg = color },
			}
			return buffer
		end,
    hide = {
      cursorline = true,
    }
	},
}
