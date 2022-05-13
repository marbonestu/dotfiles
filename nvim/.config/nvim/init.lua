require("plugins")
require("settings")
require("keymaps")

vim.cmd [[colorscheme duskfox]]

require("dap-config")
require("nvim-lsp-installer").setup {
  ensure_installed = {
    "gopls",
    "pyright",
    "jsdtls",
    "jsonls",
    "yamlls",
    "bashls",
    "tsserver",
    "sumneko_lua",
    "eslint",
    "cssmodules_ls"
  }
}
require("lsp.configs.sumneko_lua").setup()
require("lsp.configs.tsserver").setup()
require("lsp.configs.null-ls").setup()
require("lsp.utils").setup_server("terraformls", {})
require("lsp.utils").setup_server("pyright", {})
require("lsp.utils").setup_server("jsonls", {})
require("lsp.utils").setup_server("bashls", {})
