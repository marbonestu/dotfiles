local M = {}

local opts = { buffer = bufnr }
local map = vim.keymap.set

M.setup = function()
  map('n', 'gD', vim.lsp.buf.declaration, opts)
  map('n', 'gd', vim.lsp.buf.definition, opts)
  map('n', 'K', vim.lsp.buf.hover, opts)
  -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  map('n', 'gr', "<cmd>Trouble lsp_references<cr>", opts)
  map('n', '<leader>ldv', "<Cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
  map('n', '<leader>lds', "<Cmd>split | lua vim.lsp.buf.definition()<CR>", opts)
  map('n', 'gi', vim.lsp.buf.implementation, opts)
  map('n', '<leader>ls', vim.lsp.buf.signature_help, opts)
  map('n', '<leader>lj', vim.diagnostic.goto_next, opts)
  map('n', '<leader>lk', vim.diagnostic.goto_prev, opts)
  map('n', '<leader>lr', vim.lsp.buf.rename, opts)
  map('n', '<leader>li', "<cmd>LspInfo<CR>", opts)
  map('n', '<leader>lf', "<cmd>Format<CR>", opts)
  map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  map('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  map('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  map('n', '<leader>rn', vim.lsp.buf.rename, opts)
  map('n', '<leader>la', vim.lsp.buf.code_action, opts)
  -- vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)

end

return M
