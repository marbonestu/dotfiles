local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

vim.cmd("packadd packer.nvim")
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'

  -- fuzzy finder

  use({
    "nvim-telescope/telescope.nvim",
    config = function()
      require("config.telescope")
    end,
    requires = {
      -- "nvim-telescope/telescope-z.nvim",
      -- "nvim-telescope/telescope-project.nvim",
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      -- "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-dap.nvim",
      -- { "nvim-telescope/telescope-frecency.nvim", requires = "tami5/sql.nvim" }
    },
  })

  -- file tree
  use {
    "kyazdani42/nvim-tree.lua",
    config = function()
      require("config.tree")
    end,
  }

  -- motion
  use("ggandor/lightspeed.nvim")

  -- themes
  use({
    "sainnhe/sonokai",
    "rose-pine/neovim",
    "rmehri01/onenord.nvim",
    "EdenEast/nightfox.nvim",
    "folke/tokyonight.nvim",
  })

  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'onsails/lspkind-nvim'
  use "hrsh7th/cmp-path"
  use "David-Kunz/cmp-npm"
  use "saadparwaiz1/cmp_luasnip"

  -- snippets
  use { "L3MON4D3/LuaSnip",
    config = function() require("config.snippets") end,
  }
  use "rafamadriz/friendly-snippets"

  -- use { "hrsh7th/nvim-cmp", event = "InsertEnter",
  --   opt = true,
  --   config = function()
  --     require("config.cmp")
  --   end,
  --   requires = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "David-Kunz/cmp-npm",
  --     "saadparwaiz1/cmp_luasnip",
  --     { "L3MON4D3/LuaSnip", config = function() require("config.snippets") end, },
  --     "rafamadriz/friendly-snippets",
  --     {
  --       module = "nvim-autopairs",
  --       "windwp/nvim-autopairs",
  --       config = function() require("config.autopairs") end,
  --     },
  --   },
  -- }

  -- LSP
  use {
    "neovim/nvim-lspconfig",
    requires = {
      "jose-elias-alvarez/nvim-lsp-ts-utils",
      "jose-elias-alvarez/null-ls.nvim",
      "folke/lua-dev.nvim",
      "williamboman/nvim-lsp-installer",
      "ray-x/lsp_signature.nvim"
    },
  }

  -- DAP
  use { 'mfussenegger/nvim-dap' }
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use { 'Pocco81/dap-buddy.nvim' }

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = require("config.treesitter"),
  })
  use('nvim-treesitter/nvim-treesitter-textobjects')
  use("RRethy/nvim-treesitter-textsubjects")
  use("windwp/nvim-ts-autotag")
  use 'David-Kunz/treesitter-unit'

  -- Git
  use {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config.gitsigns").setup()
    end,
  }
  --
  --use {
  --    "numToStr/Comment.nvim",
  --    event = "BufRead",
  --    config = function()
  --      require("Comment").setup()
  --    end,
  --  }
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'tpope/vim-abolish'

  use 'theHamsta/nvim-dap-virtual-text'
  use 'kyazdani42/nvim-web-devicons'
  use 'ryanoasis/vim-devicons'


  if packer_bootstrap then
    require('packer').sync()
  end
end)
