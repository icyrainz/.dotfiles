return {
  "aaditeynair/conduct.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = {
    "ConductNewProject",
    "ConductLoadProject",
    "ConductLoadLastProject",
    "ConductLoadProjectConfig",
    "ConductReloadProjectConfig",
    "ConductDeleteProject",
    "ConductRenameProject",
    "ConductProjectNewSession",
    "ConductProjectLoadSession",
    "ConductProjectDeleteSession",
    "ConductProjectRenameSession",
  },
  init = function()
    require("telescope").load_extension("conduct")

    vim.keymap.set("n", "<leader>fp", "<cmd>Telescope conduct projects<CR>", { desc = "Telescope conduct projects"})
  end,
}
