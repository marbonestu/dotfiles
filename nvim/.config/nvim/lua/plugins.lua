-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost',
  { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'tpope/vim-abolish'
  use "mg979/vim-visual-multi"
  use 'ggandor/lightspeed.nvim' -- motion
  use 'RRethy/vim-illuminate'
  use { 'norcalli/nvim-colorizer.lua', config = function()
    require 'colorizer'.setup()
  end }
  use { "ellisonleao/glow.nvim", branch = 'main' }
  use {
    'caenrique/nvim-maximize-window-toggle',
    config = function()
      vim.keymap.set('n', '<leader>z', '<cmd>ToggleOnly<CR>')
    end
  }

  use {
    "nvim-neotest/neotest",
    config = function()
      require('config.neotest').setup()
    end,
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "haydenmeade/neotest-jest"
    }
  }
  -- file tree
  use { "kyazdani42/nvim-tree.lua", config = function() require("config.tree").setup() end }
  use 'kyazdani42/nvim-web-devicons'
  use 'ryanoasis/vim-devicons'
  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  -- Fuzzy finder
  use { 'ibhagwan/fzf-lua',
    config = function() require('config.fzf').setup() end,
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- themes
  use({
    "sainnhe/sonokai",
    "rose-pine/neovim",
    "rmehri01/onenord.nvim",
    "EdenEast/nightfox.nvim",
    "folke/tokyonight.nvim",
    "rebelot/kanagawa.nvim",
    { "catppuccin/nvim", as = "catppuccin" }
  })

  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      --Set statusbar
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = 'duskfox',
          component_separators = '|',
          section_separators = '',
        },
      }
    end
  }

  -- Add indentation guides even on blank lines
  use { 'lukas-reineke/indent-blankline.nvim', config = function() require("config.indent").setup() end }

  -- git
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
  use {
    'lewis6991/gitsigns.nvim',
    config = function() require("config.gitsigns").config() end,
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    config = function() require("config.treesitter").setup() end,
    requires = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      "windwp/nvim-ts-autotag",
      'David-Kunz/treesitter-unit',
      "nvim-treesitter/nvim-treesitter-refactor",
    }
  }

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
  use 'mfussenegger/nvim-jdtls'
  use { 'j-hui/fidget.nvim', config = function() require("fidget").setup() end }

  -- DAP
  --
  use { "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" } }

  use { 'mfussenegger/nvim-dap' }
  use { 'mfussenegger/nvim-dap-python', config = function()
    require("dap-python").setup('~/.virtualenvs/debugpy/bin/python')
  end }

  use { 'suketa/nvim-dap-ruby', config = function()
    local dap = require('dap')
    dap.set_log_level('TRACE')

    require('dap-ruby').setup()
  end }

  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use 'theHamsta/nvim-dap-virtual-text'
  use { "Pocco81/DAPInstall.nvim", requires = { "mfussenegger/nvim-dap" } }
  use { "jbyuki/one-small-step-for-vimkind", requires = { "mfussenegger/nvim-dap" } }

  -- Snippets
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'rafamadriz/friendly-snippets' -- Snippets plugin

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    config = function()
      require("config.cmp").setup()
    end,
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'onsails/lspkind-nvim',
      "hrsh7th/cmp-path",
      "David-Kunz/cmp-npm",
      "saadparwaiz1/cmp_luasnip",
    }
  }

  use({
    "davidgranstrom/nvim-markdown-preview", -- preview markdown output in browser
    opt = true,
    ft = { "markdown" },
    cmd = "MarkdownPreview",
  })
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }
  use { "Shatur/neovim-session-manager", config = require("config.sessions").setup }
end)
