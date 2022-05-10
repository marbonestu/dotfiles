-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'tpope/vim-abolish'
  use "mg979/vim-visual-multi"
  use 'ludovicchabant/vim-gutentags' -- Automatic tags management
  use 'ggandor/lightspeed.nvim' -- motion

  -- file tree
  use { "kyazdani42/nvim-tree.lua", config = function() require("config.tree") end }
  use 'kyazdani42/nvim-web-devicons'
  use 'ryanoasis/vim-devicons'

  -- Fuzzy finder
  use({
    "nvim-telescope/telescope.nvim",
    -- config = function() require("config.telescope") end,
    requires = {
      -- "nvim-telescope/telescope-z.nvim",
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      -- { "nvim-telescope/telescope-frecency.nvim", requires = "tami5/sql.nvim" }
      -- "nvim-telescope/telescope-dap.nvim",
    },
  })

  -- themes
  use({
    "sainnhe/sonokai",
    "rose-pine/neovim",
    "rmehri01/onenord.nvim",
    "EdenEast/nightfox.nvim",
    "folke/tokyonight.nvim",
    "rebelot/kanagawa.nvim"
  })

  use 'nvim-lualine/lualine.nvim' -- Fancier statusline

  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- git
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      "windwp/nvim-ts-autotag",
      'David-Kunz/treesitter-unit',
      "nvim-treesitter/nvim-treesitter-refactor",
    }
  }

  -- lsp
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
  use { 'j-hui/fidget.nvim', config = function() require("fidget").setup() end }

  -- DAP
  use { 'mfussenegger/nvim-dap' }
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  -- use { 'Pocco81/dap-buddy.nvim' }
  -- use { "Pocco81/DAPInstall.nvim", config = function()
  --   require("dap-install").setup({
  --     installation_path = vim.fn.stdpath("data") .. "/dapinstall/",
  --   })
  -- end
  -- }
  use 'theHamsta/nvim-dap-virtual-text'

  -- Snippets
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'rafamadriz/friendly-snippets' -- Snippets plugin

  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'onsails/lspkind-nvim'
  use "hrsh7th/cmp-path"
  use "David-Kunz/cmp-npm"
  use "saadparwaiz1/cmp_luasnip"

  use({
    "davidgranstrom/nvim-markdown-preview", -- preview markdown output in browser
    opt = true,
    ft = { "markdown" },
    cmd = "MarkdownPreview",
  })
  use { "Shatur/neovim-session-manager", config = require("config.sessions").setup }
end)

vim.g.mapleader = " "


-- vim.opt.showcmd = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true -- Save undo history
vim.opt.confirm = true -- prompt to save before destructive actions
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.pumheight = 10
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.opt.showmode = false

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'


-- GENERAL KEYMAPPING
-- escape
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("n", '<leader>w', ':w<CR>')
vim.keymap.set("n", '<leader>q', ':q<CR>')
vim.keymap.set("n", '<leader>Q', ':qa<CR>')
vim.keymap.set("n", '<leader>c', ':bdelete<CR>')
-- movement
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-d>', '3j')
vim.keymap.set('n', '<C-u>', '3k')
vim.keymap.set('n', '<C-e>', '7<C-e>')
vim.keymap.set('n', '<C-y>', '7<C-y>')
vim.keymap.set('v', '<C-d>', '3j')
vim.keymap.set('v', '<C-u>', '3k')
vim.keymap.set('v', '<C-e>', '7<C-e>')
vim.keymap.set('v', '<C-y>', '7<C-y>')



vim.keymap.set('n', 'vv', 'V')
vim.keymap.set('n', 'V', 'v$h')

-- move selected line in visual mode
vim.keymap.set('x', 'K', ':move \'<-2<CR>gv-gv')
vim.keymap.set('x', 'J', ':move \'>+1<CR>gv-gv')
-- better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.keymap.set('n', '<leader>h', ':noh<CR>', { silent = true })

vim.keymap.set('n', '<M-Up>', ':resize +5<CR>')
vim.keymap.set('n', '<M-Down>', ':resize -5<CR>')
vim.keymap.set('n', '<M-Right>', ':vertical resize +5<CR>')
vim.keymap.set('n', '<M-Left>', ':vertical resize -5<CR>')

if vim.fn.has "mac" == 1 then
  vim.keymap.set('n', '<A-Up>', '<C-Up>')
  vim.keymap.set('n', '<A-Down>', '<C-Down>')
  vim.keymap.set('n', '<A-Right>', '<C-Right>')
  vim.keymap.set('n', '<A-Left>', '<C-Left>')
end

vim.cmd [[colorscheme duskfox]]

--Set statusbar
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'duskfox',
    component_separators = '|',
    section_separators = '',
  },
}

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
  end,
})

-- Indent blankline
vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
vim.g.indent_blankline_filetype_exclude = {
  "help",
  "startify",
  "dashboard",
  "packer",
  "neogitstatus",
  "NvimTree",
  "Trouble",
}
vim.g.indentLine_enabled = 1
-- vim.g.indent_blankline_char = "│"
vim.g.indent_blankline_char = "▏"
vim.g.indent_blankline_show_trailing_blankline_indent = false
vim.g.indent_blankline_show_first_indent_level = true
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_current_context = true
vim.g.indent_blankline_context_patterns = {
  "class",
  "return",
  "function",
  "method",
  "^if",
  "^while",
  "jsx_element",
  "^for",
  "^object",
  "^table",
  "block",
  "arguments",
  "if_statement",
  "else_clause",
  "jsx_element",
  "jsx_self_closing_element",
  "try_statement",
  "catch_clause",
  "import_statement",
  "operation_type",
}
-- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
vim.wo.colorcolumn = "99999"

-- Gitsigns
require("gitsigns").setup({
  signs = {
    add = { hl = "GitSignsAdd", text = "▍", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
    change = {
      hl = "GitSignsChange",
      text = "▍",
      numhl = "GitSignsChangeNr",
      linehl = "GitSignsChangeLn",
    },
    delete = {
      hl = "GitSignsDelete",
      text = "▸",
      numhl = "GitSignsDeleteNr",
      linehl = "GitSignsDeleteLn",
    },
    topdelete = {
      hl = "GitSignsDelete",
      text = "▾",
      numhl = "GitSignsDeleteNr",
      linehl = "GitSignsDeleteLn",
    },
    changedelete = {
      hl = "GitSignsChange",
      text = "▍",
      numhl = "GitSignsChangeNr",
      linehl = "GitSignsChangeLn",
    },
  },
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,
    ["n <leader>gj"] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'" },
    ["n <leader>gk"] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'" },
    ["n <leader>gs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ["n <leader>gu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ["n <leader>gr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ["n <leader>gR"] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ["n <leader>gp"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ["n <leader>gl"] = '<cmd>lua require"gitsigns".blame_line()<CR>',
    -- Text objects
    ["o ih"] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
    ["x ih"] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
  }
})

-- Telescope
local telescope_actions = require("telescope.actions")
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<ESC>'] = telescope_actions.close,
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<c-d>'] = require('telescope.actions').delete_buffer

      },
    },
  },
}

-- -- Enable telescope fzf native
-- require('telescope').load_extension 'fzf'

--Add leader shortcuts
vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').git_files { previewer = false } end)
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers)
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').oldfiles)
vim.keymap.set('n', '<leader>st', require('telescope.builtin').grep_string)
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
-- vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "bash",
    "css",
    "javascript",
    "typescript",
    "python",
    "rust",
    "hcl",
    "json",
    "jsonc",
    "lua",
    "make",
    "markdown",
    "scss",
    "toml",
    "tsx",
    "yaml",
  },

  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  autotag = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
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
    },
    move = {
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
    },
  },
}

require("dap-config")
require("nvim-lsp-installer").setup {}
require("lsp.configs.sumneko_lua").setup()
require("lsp.configs.tsserver").setup()
require("lsp.configs.null-ls").setup()
require("lsp.utils").setup_server("terraformls", {})

-- luasnip setup
local luasnip = require 'luasnip'
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.call("stdpath", "config") .. "/snippets" } })

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  completion = {
    ---@usage The minimum length of a word to complete on.
    keyword_length = 1,
  },
  experimental = {
    ghost_text = true,
    native_menu = false,
  },
  duplicates = {
    buffer = 1,
    path = 1,
    nvim_lsp = 0,
    luasnip = 1,
  },
  duplicates_default = 0,
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = "buffer" },
    { name = "path" },
  },
}
