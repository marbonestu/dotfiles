return {
  {
    "mfussenegger/nvim-dap",
    opts = {
      require("dap.ext.vscode").load_launchjs(),
    },
    keys = {
      {
        "<leader>dfs",
        function()
          require("dapui").float_element("scopes")
        end,
        desc = "Floating Scopes",
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    opts = {
      layouts = {
        {
          elements = {
            -- Provide the elements you want to see in this layout
            { id = "scopes", size = 0.30 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40, -- The width of the layout
          position = "left", -- Can be "left", "right", "top", "bottom"
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10, -- The height of the layout
          position = "bottom", -- Can be "left", "right", "top", "bottom"
        },
      },
    },
  },
}
