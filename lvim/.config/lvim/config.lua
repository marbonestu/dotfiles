local opt = vim.opt
-- general
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "duskfox"

-----------------------------------------------------------------------------//
-- Timings {{{1
-----------------------------------------------------------------------------//
opt.updatetime = 300
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10

opt.relativenumber = true

-----------------------------------------------------------------------------//
-- Backup {{{1
-----------------------------------------------------------------------------//
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true -- Save undo history
opt.confirm = true -- prompt to save before destructive actions

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- movement
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-d>', '3j')
vim.keymap.set('n', '<C-u>', '3k')
vim.keymap.set('v', '<C-d>', '3j')
vim.keymap.set('v', '<C-u>', '3k')
vim.keymap.set('n', '<C-e>', '4<C-e>')
vim.keymap.set('n', '<C-y>', '4<C-y>')

vim.keymap.set('i', '<S-Tab>', "<BS>")
-- -- util.nnoremap('[o', '<TAB>')
-- -- util.nnoremap(']o', '<c-o>')

-- lvim.keys.normal_mode["<S-TAB>"] = ':bprevious<cr>"'
-- lvim.keys.normal_mode["<TAB>"] = ":bnext<cr>"
-----------------------------------------------------------------------------//
-- Lunar vim builtin toggle feature --
-----------------------------------------------------------------------------//
lvim.builtin.alpha.active = true
lvim.builtin.terminal.active = true
lvim.builtin.lualine.active = true
lvim.builtin.dap.active = true
lvim.builtin.test_runner = { active = true }

lvim.builtin.nvimtree.active = true
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.setup.view.width = 50
lvim.builtin.nvimtree.show_icons.git = 0


lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.autotag.enabled = true
lvim.builtin.treesitter.textobjects.select = {
  enable = true,
  disable = {},
  keymaps = {
    -- You can use the capture groups defined in textobjects.scm
    ["af"] = "@function.outer",
    ["if"] = "@function.inner",
    ["aC"] = "@class.outer",
    ["iC"] = "@class.inner",
    ["ac"] = "@conditional.outer",
    ["ic"] = "@conditional.inner",
    ["ab"] = "@block.outer",
    ["ib"] = "@block.inner",
    ["al"] = "@loop.outer",
    ["il"] = "@loop.inner",
    ["is"] = "@statement.inner",
    ["as"] = "@statement.outer",
    ["am"] = "@call.outer",
    ["im"] = "@call.inner",
    ["ad"] = "@comment.outer",
    ["id"] = "@comment.inner",
    ["ia"] = "@parameter.inner",
    ["aa"] = "@parameter.outer",
  },
}
lvim.builtin.treesitter.textobjects.move = {
  enable = true,
  set_jumps = true, -- whether to set jumps in the jumplist
  goto_next_start = {
    ["]m"] = "@function.outer",
    ["]]"] = "@class.outer",
    ["]a"] = "@parameter.inner",
    ["]b"] = "@block.inner",
  },
  goto_next_end = {
    ["]M"] = "@function.outer",
    ["]["] = "@class.outer",
    ["]A"] = "@parameter.inner",
  },
  goto_previous_start = {
    ["[m"] = "@function.outer",
    ["[["] = "@class.outer",
    ["[a"] = "@parameter.inner",
    ["[b"] = "@block.inner",
  },
  goto_previous_end = {
    ["[M"] = "@function.outer",
    ["[]"] = "@class.outer",
    ["[A"] = "@parameter.inner",
  },
}

-- Whichkey
lvim.builtin.which_key.mappings["?"] = { "<cmd>NvimTreeFindFile<cr>", "NvimTree Goto File" }

-- Telescope
local ok, actions = pcall(require, "telescope.actions")
if ok then
  lvim.builtin.telescope.defaults.mappings.i = { ["<ESC>"] = actions.close }
end


-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "prettierd",
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "typescript", "typescriptreact" },
  },
}

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  {
    command = "eslint_d",
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "javascript", "javascriptreact" },
  },
}

-- Additional Plugins
lvim.plugins = {
  { "jose-elias-alvarez/typescript.nvim", config = function()
    require("typescript").setup({
      disable_commands = false, -- prevent the plugin from creating Vim commands
      disable_formatting = false, -- disable tsserver's formatting capabilities
      debug = false, -- enable debug logging for commands
      -- server = { -- pass options to lspconfig's setup method
      --   -- on_attach = ...,
      -- },
    })
  end },
  {
    "sainnhe/sonokai",
    'Mofiqul/dracula.nvim',
    "rose-pine/neovim",
    "rmehri01/onenord.nvim",
    "EdenEast/nightfox.nvim",
    "folke/tokyonight.nvim",
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "danymat/neogen",
    config = function()
      require('neogen').setup {}
    end,
    requires = "nvim-treesitter/nvim-treesitter",
    -- Uncomment next line if you want to follow only stable versions
    -- tag = "*"
  },
  {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup()
    end,
    event = "BufRead",
  },
  {
    "unblevable/quick-scope",
    config = function()
      require "user.quickscope"
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require "user.blankline"
    end,
  },
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("user.hop").config()
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("user.colorizer").config()
    end,
  },
  "mg979/vim-visual-multi",
  {
    "folke/zen-mode.nvim",
    config = function()
      require("user.zen").config()
    end,
  },
  -- {
  --   "nvim-telescope/telescope-frecency.nvim",
  --   requires = { "tami5/sqlite.lua" }
  -- },
  { "nvim-treesitter/nvim-treesitter-textobjects", },
  { "nvim-treesitter/nvim-treesitter-refactor", },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
  },
  {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require("user.spectre").config()
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
    end,
    ft = { "typescriptreact", "javascriptreact", "python", "rust", "go" },
    requires = { "mfussenegger/nvim-dap" },
    disable = not lvim.builtin.dap.active,
  },
  { "jbyuki/one-small-step-for-vimkind", module = "osv" },
  {
    "rcarriga/vim-ultest",
    cmd = { "Ultest", "UltestSummary", "UltestNearest" },
    wants = "vim-test",
    requires = { "vim-test/vim-test" },
    run = ":UpdateRemotePlugins",
    disable = not lvim.builtin.test_runner.active,
  },
  {
    "vim-test/vim-test",
    cmd = { "TestNearest", "TestFile", "TestSuite", "TestLast", "TestVisit" },
    keys = { "<localleader>tf", "<localleader>tn", "<localleader>ts" },
    config = function()
      require("user.vim_test").config()
    end,
    disable = not lvim.builtin.test_runner.active,
  },
  { "tpope/vim-surround" },
  { "tpope/vim-abolish" },
}


require("user.dap").config()
-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
