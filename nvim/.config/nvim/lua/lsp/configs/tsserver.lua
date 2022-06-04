local M = {}

local lsputils = require "lsp.utils"

function M.lsp_attach(client, bufnr)
  lsputils.common_on_attach(client, bufnr)

  -- disable tsserver formatting if you plan on formatting via null-ls
  client.server_capabilities.document_formatting = false
  client.server_capabilities.document_range_formatting = false

  local ts_utils = require "nvim-lsp-ts-utils"

  -- defaults
  ts_utils.setup {
    debug = false,
    disable_commands = false,
    enable_import_on_completion = true,

    -- import all
    import_all_timeout = 5000, -- ms
    import_all_priorities = {
      buffers = 4, -- loaded buffer names
      buffer_content = 3, -- loaded buffer content
      local_files = 2, -- git files or files with relative path markers
      same_file = 1, -- add to existing import statement
    },
    import_all_scan_buffers = 100,
    import_all_select_source = false,

    -- eslint
    eslint_enable_code_actions = true,
    eslint_enable_disable_comments = false,
    eslint_bin = "eslint_d",
    eslint_enable_diagnostics = true,
    eslint_opts = {},

    -- formatting
    enable_formatting = false,
    formatter = "prettier",
    formatter_opts = {},

    -- update imports on file move
    update_imports_on_move = true,
    require_confirmation_on_move = true,
    watch_dir = nil,
  }

  -- required to fix code action ranges and filter diagnostics
  ts_utils.setup_client(client)

  local opts = { silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lI", ":TSLspImportAll<CR>", opts)
end

function M.config(installed_server)
  return {
    on_attach = M.lsp_attach,
    capabilities = lsputils.common_capabilities(),
    on_init = lsputils.lsp_init,
    on_exit = lsputils.lsp_exit,
    flags = { debounce_text_changes = 150 },
  }
end

function M.setup(installed_server)
  require('lspconfig').tsserver.setup({
    on_attach = M.lsp_attach,
  })
  return M.config(installed_server)
end

return M
