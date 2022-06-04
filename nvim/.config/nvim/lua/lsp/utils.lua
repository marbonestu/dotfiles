local M = {}

function M.lsp_diagnostics()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    underline = false,
    signs = true,
    update_in_insert = false,
  })

  local on_references = vim.lsp.handlers["textDocument/references"]
  vim.lsp.handlers["textDocument/references"] = vim.lsp.with(on_references, { loclist = true, virtual_text = true })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

function M.lsp_highlight(client, _)
  require 'illuminate'.on_attach(client)
end

function M.lsp_config(client, bufnr)
  require("lsp_signature").on_attach {
    bind = true,
    handler_opts = { border = "single" },
  }
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- -- Key mappings
  -- local keymap = require "utils.keymap"
  -- for mode, mapping in pairs(lsp_keymappings) do
  --   keymap.map(mode, mapping)
  -- end

  -- -- LSP and DAP menu
  -- local whichkey = require "config.whichkey"
  -- whichkey.register_lsp(client)

  if client.name == "tsserver" or client.name == "jsonls" then
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end

  if client.server_capabilities.document_formatting then
    vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()"
  end
end

function M.common_on_init(client, bufnr)
  -- LSP init
end

function M.common_on_exit(client, bufnr)
  -- LSP exit
end

function M.common_on_attach(client, bufnr)
  M.lsp_config(client, bufnr)
  M.lsp_highlight(client, bufnr)
  M.lsp_diagnostics()

  vim.api.nvim_create_user_command("Format", function()
    vim.lsp.buf.format { async = true }
  end, {})

  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gr', "<cmd>Trouble lsp_references<cr>", opts)
  vim.keymap.set('n', '<leader>ldv', "<Cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
  vim.keymap.set('n', '<leader>lds', "<Cmd>split | lua vim.lsp.buf.definition()<CR>", opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>lj', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>lk', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>li', "<cmd>LspInfo<CR>", opts)
  vim.keymap.set('n', '<leader>lf', "<cmd>Format<CR>", opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
end

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- for nvim-cmp
  capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

  -- Code actions
  capabilities.textDocument.codeAction = {
    dynamicRegistration = true,
    codeActionLiteralSupport = {
      codeActionKind = {
        valueSet = (function()
          local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
          table.sort(res)
          return res
        end)(),
      },
    },
  }

  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.experimental = {}
  capabilities.experimental.hoverActions = true

  return capabilities
end

function M.make_default_config()
  return {
    on_attach = M.common_on_attach,
    on_exit = M.common_on_exit,
    on_init = M.common_on_init,
    capabilities = M.common_capabilities(),
    flags = { debounce_text_changes = 150 },
  }
end

function M.setup_server(server, config)
  local options = M.make_default_config()
  for k, v in pairs(config) do
    options[k] = v
  end

  local lspconfig = require "lspconfig"
  lspconfig[server].setup(vim.tbl_deep_extend("force", options, {}))
end

return M
