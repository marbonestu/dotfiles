-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
-- local del = vim.keymap.del
local Util = require("lazyvim.util")

-- Visual-multi
map("i", "jj", "<ESC>")
map("n", "<leader>Q", ":qa<CR>")

map("n", "gh", "^")
map("n", "gl", "$")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-d>", "5j")
map("n", "<C-u>", "5k")
map("n", "<C-e>", "9<C-e>")
map("n", "<C-y>", "9<C-y>")
map("v", "<C-e>", "9<C-e>")
map("v", "<C-y>", "9<C-y>")
map("v", "<C-d>", "5j")
map("v", "<C-u>", "5k")
map("v", "<C-u>", "7k")
map("n", "<C-a>", "ggVG")
map("n", "ZL", "25zl")
map("n", "ZH", "25zh")

map("n", "v$", "v$h")

-- -- move selected line in visual mode
map("x", "K", ":move '<0<CR>gv-gv")
map("x", "J", ":move '>+3<CR>gv-gv")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<leader>h", ":noh<CR>", { silent = true })
map("n", "<ESC>", ":noh<CR>", { silent = true, remap = true })

map("n", "<A-Up>", ":resize +6<CR>")
map("n", "<A-Down>", ":resize -4<CR>")
map("n", "<A-Right>", ":vertical resize +6<CR>")
map("n", "<A-Left>", ":vertical resize -4<CR>")
map("n", "gm", ":call cursor(1, len(getline('.'))/2)<CR>")
