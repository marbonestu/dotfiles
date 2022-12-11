local M = {}
local keymap = vim.keymap.set

function M.setup()
	local neotest = require("neotest")
	require("neotest").setup({
		summary = {
			mappings = {
				expand = { "zo", "zc" },
				expand_all = { "zO", "zC" },
				stop = "x",
				jumpto = "<CR>",
			},
		},
		adapters = {
			require("neotest-plenary"),
			require("neotest-rust"),
			require("neotest-jest")({
				jestCommand = "npm test --",
				jestConfigFile = "custom.jest.config.ts",
				env = { CI = true },
				cwd = function(path)
					return vim.loop.cwd()
				end,
			}),
		},
	})

	keymap("n", "<leader>tt", neotest.run.run)
	keymap("n", "<leader>tf", function()
		neotest.run.run(vim.fn.expand("%"))
	end)
	keymap("n", "<leader>td", function()
		neotest.run.run({ strategy = "dap" })
	end)
	keymap("n", "<leader>tx", neotest.run.stop)
	keymap("n", "<leader>ta", neotest.run.attach)
	keymap("n", "<leader>ts", neotest.summary.open)
	keymap("n", "<leader>to", neotest.output.open)
end

return M
