local M = {}

function M.config()
  require("gitsigns").setup({
    signs = {
      add = { hl = "GitSignsAdd", text = "▍", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
      change = {
        hl = "GitSignsChange",
        text = "▍",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
      delete = {
        hl = "GitSignsDelete",
        text = "▸",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      topdelete = {
        hl = "GitSignsDelete",
        text = "▾",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      changedelete = {
        hl = "GitSignsChange",
        text = "▍",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
    },

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', '<leader>gj', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      map('n', '<leader>gk', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      -- Actions
      map({ 'n', 'v' }, '<leader>g', ':Gitsigns stage_hunk<CR>')
      map({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>')
      map('n', '<leader>gS', gs.stage_buffer)
      map('n', '<leader>gu', gs.undo_stage_hunk)
      map('n', '<leader>gR', gs.reset_buffer)
      map('n', '<leader>gp', gs.preview_hunk)
      map('n', '<leader>gb', function() gs.blame_line { full = true } end)
      map('n', '<leader>gl', gs.blame_line)
      map('n', '<leader>gL', '<cmd>G blame<CR>')
      map('n', '<leader>gd', gs.diffthis)
      map('n', '<leader>gD', function() gs.diffthis('~') end)
      map('n', '<leader>gd', gs.toggle_deleted)

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end
  })
end

return M
