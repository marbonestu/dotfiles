local M = {}

function M.setup()
  local actions = require('fzf-lua').actions
  require('fzf-lua').setup {
    winopts = {
      preview = {
        -- layout = 'vertical'
      }
    },
    oldfiles = {
      prompt                  = 'History❯ ',
      cwd_only                = true,
      stat_file               = true,
      include_current_session = true,
    },
    git_bcommits = {
      preview = { layout = 'horizontal' }
    },
    git_diff = {
      pager = "delta --width $FZF_PREVIEW_COLUMNS"
    }
  }


  vim.keymap.set('n', '<leader>f', function() require('fzf-lua').files({ continue_last_search = false }) end)
  vim.keymap.set('n', '<leader>sb', function() require('fzf-lua').buffers({ continue_last_search = false }) end)
  vim.keymap.set('n', '<leader>sr', function() require('fzf-lua').oldfiles({ continue_last_search = false }) end)
  vim.keymap.set('n', '<leader>st', function() require('fzf-lua').live_grep({ continue_last_search = false }) end)
  vim.keymap.set('n', '<leader>sp', function() require('fzf-lua').resume() end)
  vim.keymap.set('n', '<leader>gb', function() require('fzf-lua').git_bcommits() end)

end

return M
