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

require('plugins')

vim.cmd [[colorscheme nightfox]]

-- escape
vim.keymap.set("i", "jj", "<ESC>")

-- movement
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-d>', '3j')
vim.keymap.set('n', '<C-u>', '3k')
vim.keymap.set('n', '<C-e>', '4<C-e>')
vim.keymap.set('n', '<C-y>', '4<C-y>')

-- move selected line in visual mode
vim.keymap.set('x', 'K', ':move \'<-2<CR>gv-gv')
vim.keymap.set('x', 'J', ':move \'>+1<CR>gv-gv')

-- better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- vim.keymap.set("n", "<Leader>f", function() require("fzf-lua").files() end)
-- vim.keymap.set("n", "<Leader>sr", function() require("fzf-lua").oldfiles() end)

-- autocommands
-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
    end,
})

-- terminals
vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        -- disable line numbers
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        -- always start in insert mode
        vim.cmd("startinsert")
    end,
})



require('nvim-tree').setup({
  hijack_cursor = true,
  update_focused_file = { enable = true },
  view = {
    width = 60
  }
})
