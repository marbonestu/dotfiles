local servers = {
  -- "bashls",
  -- "clangd",
  -- "cssls",
  -- "eslint",
  -- "jsonls",
  -- "pyright",
  "sumneko_lua",
  "tsserver",
}

require("lsp.manager").setup(servers)
