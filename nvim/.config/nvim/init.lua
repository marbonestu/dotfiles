--
-- bootstrap lazy.nvim, LazyVim and your plugins
BORDER_STYLE = "rounded"
require("config.lazy")

-- Source - https://stackoverflow.com/questions/78611905/turn-off-neovim-messages-in-vscode
-- Posted by Sumanth Lingappa
-- Retrieved 2025-11-06, License - CC BY-SA 4.0

if vim.g.vscode then
  cmdheight = 1 -- this is the new line I added
  return
end

-- rest of the nvim config
