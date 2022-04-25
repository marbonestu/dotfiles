vim.g.mapleader = " "

vim.opt.showcmd = false
vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.cmd [[colorscheme nightfox]]

require('plugins')

vim.keymap.set("n", "<Leader>f", function() require("fzf-lua").files() end)
vim.keymap.set("n", "<Leader>sr", function() require("fzf-lua").oldfiles() end)

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
