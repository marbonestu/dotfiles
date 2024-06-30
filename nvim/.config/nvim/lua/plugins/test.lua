return {
  { "nvim-neotest/neotest-plenary" },
  { "haydenmeade/neotest-jest" },
  { "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-jest", "neotest-vitest", "neotest-plenary", ["rustaceanvim.neotest"] = {} } },
    requires = { "haydenmeade/neotest-jest", "marilari88/neotest-vitest", "mrcjkb/rustaceanvim" },
    keys = {
      {
        "<leader>ts",
        function()
          require("neotest").summary.open()
          local win = vim.fn.bufwinid("Neotest Summary")
          if win > -1 then
            vim.api.nvim_set_current_win(win)
          end
        end,
        desc = "Toggle Summary",
      },
    },
  },
}
