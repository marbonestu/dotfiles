local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

vim.cmd("packadd packer.nvim")
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use { 'ibhagwan/fzf-lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function() require('config.fzf').setup() end,
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

  use 'kyazdani42/nvim-tree.lua'
  use 'David-Kunz/treesitter-unit'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/nvim-cmp'
  use 'onsails/lspkind-nvim'
  use 'David-Kunz/cmp-npm'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
