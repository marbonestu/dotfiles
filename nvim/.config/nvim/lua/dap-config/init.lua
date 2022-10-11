local dap = require('dap')

require("dap-vscode-js").setup({
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  debugger_path = "/Users/marbones-remote/vscode-js-debug", -- Path to vscode-js-debug installation.
  -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
  require("dap").configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require 'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    }
  }
end

-- require('dap').set_log_level('INFO')
dap.defaults.fallback.terminal_win_cmd = '20split new'
vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '🟦', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '⭐️', texthl = '', linehl = '', numhl = '' })

vim.keymap.set('n', '<leader>db', function() require "dap".toggle_breakpoint() end)
vim.keymap.set('n', '<leader>dB', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set('n', '<leader>dk', function() require "dap".step_out() end)
vim.keymap.set('n', '<leader>dj', function() require "dap".step_into() end)
vim.keymap.set('n', '<leader>dl', function() require "dap".step_over() end)
vim.keymap.set('n', '<leader>dd', function() require "dap".continue() end)
vim.keymap.set('n', '<leader>dn', function() require "dap".run_to_cursor() end)
vim.keymap.set('n', '<leader>dc', function() require "dap".terminate() end)
vim.keymap.set('n', '<leader>dR', function() require "dap".clear_breakpoints() end)
vim.keymap.set('n', '<leader>de', function() require "dap".set_exception_breakpoints({ "all" }) end)
vim.keymap.set('n', '<leader>da', function() require "debugHelper".attach() end)
vim.keymap.set('n', '<leader>dA', function() require "debugHelper".attachToRemote() end)
vim.keymap.set('n', '<leader>dK', function() require "dap.ui.widgets".hover() end)
vim.keymap.set('n', '<leader>d?',
  function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end)

-- nvim-telescope/telescope-dap.nvim
-- require('telescope').load_extension('dap')
-- vim.keymap.set('n', '<leader>ds', ':Telescope dap frames<CR>')
-- -- vim.keymap.set('n', '<leader>dc', ':Telescope dap commands<CR>')
-- vim.keymap.set('n', '<leader>db', ':Telescope dap list_breakpoints<CR>')

require('nvim-dap-virtual-text').setup()
require("dapui").setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7"),
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
  }
})
