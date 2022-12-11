require("plugins")
require("settings")
require("keymaps")
require("commands")
require("config.tmux")
require("config.lsp").config()
require("config.dap")

vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha

require("catppuccin").setup()

vim.cmd([[colorscheme catppuccin]])
