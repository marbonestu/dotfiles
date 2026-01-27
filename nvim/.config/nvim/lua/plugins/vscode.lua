-- Configurations when using vscode-neovim.
-- Modified from https://github.com/LazyVim/LazyVim/raw/main/lua/lazyvim/plugins/extras/vscode.lua
-- Note: cmdheight, shortmess, and report settings are in lua/config/options.lua

if not vim.g.vscode then
  return {}
end

local enabled = {
  "lazy.nvim",
  "mini.ai",
  "mini.comment",
  -- "mini.pairs",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  "vim-repeat",
  "LazyVim",
  "snacks.nvim",  -- Added to fix Snacks error in VSCode/Cursor
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

-- Add some vscode specific keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  callback = function()
    -- vim.keymap.set("n", "H", function()
    --   require("vscode-neovim").call("workbench.action.previousEditor")
    -- end)
    -- vim.keymap.set("n", "L", function()
    --   require("vscode-neovim").call("workbench.action.nextEditor")
    -- end)
    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
      require("vscode-neovim").call("editor.action.quickFix")
    end)
    vim.keymap.set({ "n", "x" }, "<leader>cr", function()
      require("vscode-neovim").call("editor.action.rename")
    end)
    vim.keymap.set("n", "<leader>cf", function()
      require("vscode-neovim").call("editor.action.formatDocument")
    end)
    vim.keymap.set("n", "<leader>co", function()
      require("vscode-neovim").call("editor.action.organizeImports")
    end)
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")

    vim.keymap.set("n", "<A-Right>", function()
      require("vscode-neovim").call("workbench.action.increaseViewSize")
    end)
    vim.keymap.set("n", "<A-Left>", function()
      require("vscode-neovim").call("workbench.action.decreaseViewSize")
    end)

    vim.keymap.set("n", "gr", function()
      require("vscode-neovim").call("editor.action.goToReferences")
    end)

    local map = vim.keymap.set

    -- map("n", "<C-e>", "9<C-e>")
    -- map("n", "<C-y>", "9<C-y>")
    -- map("v", "<C-e>", "9<C-e>")
    -- map("v", "<C-y>", "9<C-y>")
    -- map("n", "<C-a>", "ggVG")
    -- map("n", "ZL", "25zl")
    -- map("n", "ZH", "25zh")
    --
    -- map("n", "v$", "v$h")
    --
    -- -- -- move selected line in visual mode
    -- map("x", "K", ":move '<0<CR>gv-gv")
    -- map("x", "J", ":move '>+3<CR>gv-gv")
    --
    -- -- better indenting
    -- map("v", "<", "<gv")
    -- map("v", ">", ">gv")
    -- map("n", "<leader>h", ":noh<CR>", { silent = true })
    -- map("n", "<ESC>", ":noh<CR>", { silent = true, remap = true })
    --
    -- map("n", "<A-Up>", ":resize +6<CR>")
    -- map("n", "<A-Down>", ":resize -4<CR>")
    -- map("n", "<A-Right>", ":vertical resize +6<CR>")
    -- map("n", "<A-Left>", ":vertical resize -4<CR>")
    -- map("n", "gm", ":call cursor(1, len(getline('.'))/2)<CR>")
  end,
})

return {
  {
    "LazyVim/LazyVim",
    config = function(_, opts)
      opts = opts or {}
      -- disable the colorscheme
      opts.colorscheme = function() end
      require("lazyvim").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = false },
      rainbow = { enable = false },
    },
  },
}
