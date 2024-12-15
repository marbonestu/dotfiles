return {
  {
    "folke/persistence.nvim",
    keys = function()
      return {
        {
          "<leader>ls",
          function()
            require("persistence").load()
          end,
          desc = "Restore Session",
        },
        {
          "<leader>ql",
          false,
          -- function()
          --   require("persistence").load({ last = true })
          -- end,
          desc = "Restore Last Session",
        },
        {
          "<leader>qd",
          false,
          -- function()
          --   require("persistence").stop()
          -- end,
          desc = "Don't Save Current Session",
        },
      }
    end,
  },
}
