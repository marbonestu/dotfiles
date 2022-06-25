local M = {}

function M.setup()
  local actions = require('fzf-lua').actions
  require('fzf-lua').setup {
    winopts = {
      preview = {
        layout = 'vertical'
      }
    },
    oldfiles = {
      prompt                  = 'History❯ ',
      cwd_only                = true,
      stat_file               = true, -- verify files exist on disk
      include_current_session = false, -- include bufs from current session
    },
  }


  vim.keymap.set('n', '<leader>f', function() require('fzf-lua').files() end)
  vim.keymap.set('n', '<leader>sb', function() require('fzf-lua').buffers() end)
  vim.keymap.set('n', '<leader>sr', function() require('fzf-lua').oldfiles() end)
  vim.keymap.set('n', '<leader>st', function() require('fzf-lua').live_grep() end)

end

return M
