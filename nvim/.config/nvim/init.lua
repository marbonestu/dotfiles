require("plugins")
require("settings")
require("keymaps")

vim.cmd [[colorscheme duskfox]]

require("dap-config")
require("nvim-lsp-installer").setup {}
require("lsp.configs.sumneko_lua").setup()
require("lsp.configs.tsserver").setup()
require("lsp.configs.null-ls").setup()
require("lsp.utils").setup_server("terraformls", {})

