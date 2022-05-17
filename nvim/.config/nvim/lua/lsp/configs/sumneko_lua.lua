local M = {}

local lsputils = require "lsp.utils"

-- DATA_PATH = vim.fn.stdpath "data"

function M.config()
  return {
    library = { vimruntime = true, types = true, plugins = true },
    lspconfig = {
      capabilities = lsputils.common_capabilities(),
      on_attach = lsputils.common_on_attach,
      on_init = lsputils.common_on_init,
      on_exit = lsputils.common_on_exit,
      -- cmd_env = installed_server._default_options.cmd_env,
      settings = {
        Lua = {
          telemetry = {
            enable = false,
          },
          runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ";"),
          },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = {
              [vim.fn.expand "$VIMRUNTIME/lua"] = true,
              [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
            },
            maxPreload = 100000,
            preloadFileSize = 1000,
          },
        },
      },
    },
  }
end

function M.setup()
  local luadev = require("lua-dev").setup(M.config())
  local lspconfig = require "lspconfig"
  lspconfig.sumneko_lua.setup(luadev)
end

return M
