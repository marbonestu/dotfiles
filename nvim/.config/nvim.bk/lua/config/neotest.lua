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

	keymap("n", "<leader>Tt", neotest.run.run)
	keymap("n", "<leader>Tf", function()
		neotest.run.run(vim.fn.expand("%"))
	end)
	keymap("n", "<leader>Td", function()
		neotest.run.run({ strategy = "dap" })
	end)
	keymap("n", "<leader>Tx", neotest.run.stop)
	keymap("n", "<leader>Ta", neotest.run.attach)
	keymap("n", "<leader>Ts", neotest.summary.open)
	keymap("n", "<leader>To", neotest.output.open)
end

return M
