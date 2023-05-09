local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'MunifTanjim/nui.nvim'

  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
  }

  -- Theme
  -- use({
  --  'rose-pine/neovim',
  --  as = 'rose-pine',
  --  config = function()
  --   vim.cmd('colorscheme rose-pine')
  --  end
  -- })
  use "rebelot/kanagawa.nvim"

  -- Git
  use 'tpope/vim-fugitive'

  -- Treesitter
  use(
    'nvim-treesitter/nvim-treesitter',
    { run = ':TSUpdate' }
  )
  use 'nvim-treesitter/nvim-treesitter-context'
  -- use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- Icons
  use 'nvim-tree/nvim-web-devicons'

  -- LSP
  use {
    'williamboman/mason.nvim',
    run = function()
      pcall(vim.cmd, 'MasonUpdate')
    end,
  }
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason-lspconfig.nvim'
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
  }
  use 'WhoIsSethDaniel/mason-tool-installer.nvim'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  -- use 'hrsh7th/cmp-buffer'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  use 'jose-elias-alvarez/null-ls.nvim'

  -- Rust stuffs
  use 'simrat39/rust-tools.nvim'
  use 'rust-lang/rust.vim'
  use {
    'saecki/crates.nvim',
    tag = 'v0.3.0'
  }

  -- Typescript stuffs
  use 'jose-elias-alvarez/typescript.nvim'
  use 'MunifTanjim/prettier.nvim'

  -- Debugger
  use 'mfussenegger/nvim-dap'
  use 'theHamsta/nvim-dap-virtual-text'
  use 'rcarriga/nvim-dap-ui'
  --

  -- File explorer
  -- use 'nvim-tree/nvim-tree.lua'
  -- use {
  -- "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v2.x",
  -- }

  use 'mbbill/undotree'

  -- use({
  --   "kylechui/nvim-surround",
  --   tag = "*", -- Use for stability; omit to use `main` branch for the latest features
  --   config = function()
  --     require("nvim-surround").setup({ })
  --   end
  -- })

  -- Terminal
  use 'voldikss/vim-floaterm'
  use {
    'akinsho/toggleterm.nvim',
    tag = '*',
    config = function()
      require("toggleterm").setup()
    end
  }

  -- use {
  --     "windwp/nvim-autopairs",
  --     config = function()
  --         require("nvim-autopairs").setup {}
  --     end
  -- }

  -- Utilities
  -- use 'theprimeagen/harpoon'
  -- use {
  --     'numToStr/Comment.nvim',
  --     config = function()
  --         require('Comment').setup()
  --     end
  -- }
  -- use "lukas-reineke/indent-blankline.nvim"

  -- use 'nvim-lualine/lualine.nvim'

  -- use "github/copilot.vim"
  use 'zbirenbaum/copilot.lua'
  use 'zbirenbaum/copilot-cmp'

  -- use 'ThePrimeagen/vim-be-good'

  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup()
    end,
  }

  use {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require('neoclip').setup()
    end,
  }

  use 'stevearc/dressing.nvim'

  use 'folke/which-key.nvim'

  use 'tommcdo/vim-exchange'
  use 'tpope/vim-abolish'

  use 'folke/trouble.nvim'

  use 'echasnovski/mini.nvim'

  use 'tamago324/lir.nvim'

  use 'lewis6991/gitsigns.nvim'

  use 'weilbith/nvim-code-action-menu'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
