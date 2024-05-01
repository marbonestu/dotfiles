return {
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
  },
  {
    "GCBallesteros/NotebookNavigator.nvim",
    keys = {
      {
        "]h",
        function()
          require("notebook-navigator").move_cell("d")
        end,
      },
      {
        "[h",
        function()
          require("notebook-navigator").move_cell("u")
        end,
      },
      { "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
      { "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
    },
    dependencies = {
      "echasnovski/mini.comment",
      "hkupty/iron.nvim",
      "anuvyklack/hydra.nvim",
    },
    event = "VeryLazy",
    config = function()
      local nn = require("notebook-navigator")
      nn.setup({ activate_hydra_keys = "<leader>h" })
    end,
  },
}
