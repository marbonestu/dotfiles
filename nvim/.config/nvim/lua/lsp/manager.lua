local lsp_utils = require("lsp.utils")

local M = {}

-- function M.install_missing(servers)
--   local lspi_servers = require("nvim-lsp-installer.servers")
--   for server, _ in pairs(servers) do
--     local ok, s = lspi_servers.get_server(server)
--     if ok then
--       if not s:is_installed() then
--         s:install()
--       end
--     else
--       lsp_utils.error("Server " .. server .. " not found")
--     end
--   end
-- end

-- function M.setup(servers)
--   local lspi = require("nvim-lsp-installer")
--   local lspconfig = require("lspconfig")
--   lspi.setup({
--     ensure_installed = servers
--   })
--   for _, server in pairs(servers) do
--     local exists, server_module = pcall(require, "lsp." .. server)
--     if exists then
--       local server_opts = server_module.setup(server)

--       lspconfig[server].setup(server_opts)
--     else
--       local lsputils = require "lsp.utils"
--       local opts = {
--         on_attach = lsputils.lsp_attach,
--         capabilities = lsputils.get_capabilities(),
--         on_init = lsputils.lsp_init,
--         on_exit = lsputils.lsp_exit,
--       }
--       -- lsputils.setup_server(server,opts)
--       lspconfig[server].setup(opts)
--     end
--   end
-- end

local function resolve_config(server_name, ...)
  local defaults = {
    on_attach = lsp_utils.common_on_attach,
    on_init = lsp_utils.common_on_init,
    on_exit = lsp_utils.common_on_exit,
    capabilities = lsp_utils.common_capabilities(),
  }

  local has_custom_provider, custom_config = pcall(require, "lsp/configs/" .. server_name)
  if has_custom_provider then
    -- Log:debug("Using custom configuration for requested server: " .. server_name)
    defaults = vim.tbl_deep_extend("force", defaults, custom_config)
  end

  defaults = vim.tbl_deep_extend("force", defaults, ...)

  return defaults
end

local function launch_server(server_name, config)
  pcall(function()
    require("lspconfig")[server_name].setup(config)
  end)
end

function M.setup(servers)
  local servers = require "nvim-lsp-installer.servers"
  for _, server_name in ipairs(servers) do
    local server_available, server = servers.get_server(server_name)

    if not server_available then
      local config = resolve_config(server_name, user_config)
      launch_server(server_name, config)
      return
    end

    local install_in_progress = false

    if not server:is_installed() then
      if lvim.lsp.automatic_servers_installation then
        -- Log:debug "Automatic server installation detected"
        server:install()
        install_in_progress = true
      else
        -- Log:debug(server.name .. " is not managed by the automatic installer")
      end
    end

    server:on_ready(function()
      if install_in_progress then
        vim.notify(string.format("Installation complete for [%s] server", server.name), vim.log.levels.INFO)
      end
      install_in_progress = false
      local config = resolve_config(server_name, server:get_default_options())
      launch_server(server_name, config)
    end)
  end
end

return M
