local M = {}

function M.setup()
  require("neotest").setup({
    adapters = {
      -- require("neotest-python")({
      --   dap = { justMyCode = false },
      -- }),
      -- require("neotest-plenary"),
      -- require("neotest-vim-test")({
      --   ignore_file_types = { "python", "vim", "lua" },
      -- }),
      require('neotest-jest')({
        jestCommand = "npm test --",
        -- jestConfigFile = "custom.jest.config.ts",
      }),
    },
  })
end

return M
