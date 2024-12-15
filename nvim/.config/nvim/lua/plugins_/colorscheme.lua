return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "night" },
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, opts = {} },
  -- example lazy.nvim install setup
  {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    -- init = function()
    --   vim.cmd.colorscheme("lackluster")
    --   -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
    --   -- vim.cmd.colorscheme("lackluster-mint")
    -- end,
  },
  {
    "sho-87/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "catppuccin-mocha",
  --   },
  -- },
}
