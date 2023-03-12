local servers = {
  -- "bashls",
  -- "clangd",
  -- "cssls",
  -- "eslint",
  -- "jsonls",
  -- "pyright",
  "lua_ls",
  "tsserver",
}

require("lsp.manager").setup(servers)
