-- GENERAL KEYMAPPING
-- escape
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("n", '<leader>w', ':w<CR>')
vim.keymap.set("n", '<leader>q', ':q<CR>')
vim.keymap.set("n", '<leader>Q', ':qa<CR>')
vim.keymap.set("n", '<leader>c', ':bdelete<CR>')
-- movement
vim.keymap.set('n', 'gh', '^')
vim.keymap.set('n', 'gl', '$')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-d>', '5j')
vim.keymap.set('n', '<C-u>', '5k')
vim.keymap.set('n', '<C-e>', '9<C-e>')
vim.keymap.set('n', '<C-y>', '9<C-y>')
vim.keymap.set('v', '<C-e>', '9<C-e>')
vim.keymap.set('v', '<C-y>', '9<C-y>')
vim.keymap.set('v', '<C-d>', '5j')
vim.keymap.set('v', '<C-u>', '5k')
vim.keymap.set('v', '<C-u>', '7k')
vim.keymap.set('n', '<C-a>', "ggVG")
vim.keymap.set('n', 'ZL', "25zl")
vim.keymap.set('n', 'ZH', "25zh")

vim.keymap.set('n', 'v$', 'v$h')

-- move selected line in visual mode
vim.keymap.set('x', 'K', ':move \'<0<CR>gv-gv')
vim.keymap.set('x', 'J', ':move \'>+3<CR>gv-gv')
-- better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.keymap.set('n', '<leader>h', ':noh<CR>', { silent = true })

vim.keymap.set('n', '<ESC>', ':noh<CR>', { silent = true, remap = true })

vim.keymap.set('n', '<A-Up>', ':resize +6<CR>')
vim.keymap.set('n', '<A-Down>', ':resize -4<CR>')
vim.keymap.set('n', '<A-Right>', ':vertical resize +6<CR>')
vim.keymap.set('n', '<A-Left>', ':vertical resize -4<CR>')
vim.keymap.set('n', 'gm', ":call cursor(1, len(getline('.'))/2)<CR>")
