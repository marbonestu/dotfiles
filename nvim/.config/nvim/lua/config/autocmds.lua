-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
-- local function augroup(name)
--   return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
-- end
--
-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
--   callback = function()
--     require("persistence").load({ last = true })
--   end,
-- })
--

-- Close a window and return to the last window you jumped from
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function()
    local bufname = vim.fn.bufname()
    if bufname == "Neotest Summary" then
      local current_win = vim.fn.winnr()
      vim.cmd("wincmd p")
      local prev_win = vim.fn.winnr()
      if prev_win == current_win then
        vim.cmd("wincmd w")
      end
    end
  end,
})
