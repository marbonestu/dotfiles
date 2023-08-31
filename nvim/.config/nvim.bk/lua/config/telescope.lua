local M = {}

function M.setup()
  local telescope_actions = require("telescope.actions")
  require('telescope').setup {
    defaults = {
      file_ignore_patterns = { "node_modules", "git" },
      mappings = {
        i = {
          ['<ESC>'] = telescope_actions.close,
          ['<C-u>'] = false,
          ['<C-d>'] = false,
          ['<c-d>'] = require('telescope.actions').delete_buffer

        },
      },
    },
  }

  require('telescope').load_extension('projects')

  --Add leader shortcuts
  vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').find_files { previewer = false, hidden = true } end)
  vim.keymap.set('n', '<leader>sb', function() require('telescope.builtin').buffers { previewer = false } end)
  vim.keymap.set('n', '<leader>sr', function() require('telescope.builtin').oldfiles { previewer = false } end)
  vim.keymap.set('n', '<leader>st', require('telescope.builtin').live_grep)
  vim.keymap.set('n', '<leader>sp', '<cmd>Telescope projects<cr>')
end

return M
