require("plugins")
require("settings")
require("keymaps")
require("config.tmux")

-- vim.cmd [[colorscheme duskfox]]
vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha

require("catppuccin").setup()

vim.cmd [[colorscheme catppuccin]]

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
require("lsp.utils").setup_server("solargraph", {})
require("lsp.utils").setup_server("bashls", {})
require("lsp.utils").setup_server("gopls", {})
require("lsp.utils").setup_server("eslint", {})
require("lsp.utils").setup_server("yamlls", {
  settings = {
    schemas = {}
  }
})
require("lsp.utils").setup_server("kotlin_language_server", {})
require("lsp.utils").setup_server("rust_analyzer", {
  settings = {
    ["rust_analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = {
        command = "clippy",
        extraArgs = { "--no-deps" },
      }
    }
  }
})

-- Jump to last accessed window on closing the current one
WinCloseJmp = function()
  -- Exclude floating windows
  if '' ~= vim.api.nvim_win_get_config(0).relative then return end
  -- Record the window we jump from (previous) and to (current)
  if nil == vim.t.winid_rec then
    vim.t.winid_rec = { prev = vim.fn.win_getid(), current = vim.fn.win_getid() }
  else
    vim.t.winid_rec = { prev = vim.t.winid_rec.current, current = vim.fn.win_getid() }
  end

  -- Loop through all windows to check if the previous one has been closed
  for winnr = 1, vim.fn.winnr('$') do
    if vim.fn.win_getid(winnr) == vim.t.winid_rec.prev then
      return -- Return if previous window is not closed
    end
  end

  vim.cmd [[ wincmd p ]]
end

vim.cmd [[ autocmd VimEnter,WinEnter * lua WinCloseJmp() ]]
