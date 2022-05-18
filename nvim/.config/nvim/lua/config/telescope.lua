local M = {}

function M.setup()
  local telescope_actions = require("telescope.actions")
  require('telescope').setup {
    defaults = {
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

  --Add leader shortcuts
  vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').find_files { previewer = false } end)
  vim.keymap.set('n', '<leader>sb', function() require('telescope.builtin').buffers { previewer = false } end)
  vim.keymap.set('n', '<leader>sr', function() require('telescope.builtin').oldfiles { previewer = false } end)
  vim.keymap.set('n', '<leader>st', require('telescope.builtin').grep_string)
  vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
  -- vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
end

return M
