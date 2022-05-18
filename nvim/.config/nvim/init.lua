require("plugins")
require("settings")
require("keymaps")
require("config.tmux")

vim.cmd [[colorscheme duskfox]]

require("dap-config")
require("nvim-lsp-installer").setup {
  ensure_installed = {
    "gopls",
    "pyright",
    "jdtls",
    "jsonls",
    "yamlls",
    "bashls",
    "tsserver",
    "sumneko_lua",
    "eslint",
    "cssmodules_ls",
    "rust_analyzer"
  }
}
require("lsp.configs.sumneko_lua").setup()
require("lsp.configs.tsserver").setup()
require("lsp.configs.null-ls").setup()
require("lsp.utils").setup_server("terraformls", {})
require("lsp.utils").setup_server("pyright", {})
require("lsp.utils").setup_server("jsonls", {})
require("lsp.utils").setup_server("bashls", {})
require("lsp.utils").setup_server("gopls", {})
require("lsp.utils").setup_server("yamlls", {})
require("lsp.utils").setup_server("kotlin_language_server", {})
require("lsp.utils").setup_server("rust_analyzer", {
  settings = {
    ["rust_analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = {
        command = "clippy",
        extraArgs = {"--no-deps"},
      }
    }
}})

