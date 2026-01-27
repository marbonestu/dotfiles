-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

vim.g.lazyvim_picker = "telescope"
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.swapfile = false
vim.opt.backup = false

-- folding
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- VSCode/Cursor specific settings (when using vscode-neovim)
if vim.g.vscode then
  -- Debug: Print to verify this code is running
  print("🔧 VSCode mode detected - applying custom settings")
  
  -- Suppress vscode-neovim output messages (e.g., "1 change; before #2" when pressing 'u' to undo)
  -- Increase cmdheight to prevent auto-opening the Output panel
  vim.o.cmdheight = 20
  print("✓ cmdheight set to: " .. vim.o.cmdheight)
  
  -- Add shortmess flags to suppress more messages
  vim.opt.shortmess:append("c")  -- Don't give completion messages
  vim.opt.shortmess:append("F")  -- Don't give file info when editing
  vim.opt.shortmess:append("W")  -- Don't give "written" when writing
  
  -- Set report to a high value to suppress "X lines changed" messages
  vim.opt.report = 9999
  print("✓ report set to: " .. vim.o.report)
  print("✓ shortmess: " .. vim.o.shortmess)
else
  print("❌ Not in VSCode mode (vim.g.vscode is false/nil)")
end
