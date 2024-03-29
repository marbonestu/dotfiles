local M = {}
local lsp_utils = require("config.lsp.utils")
local servers = require("config.lsp.servers")

function M.config()
	require("neoconf").setup()
	lsp_utils.setup_lsp()

	local options = {
		on_attach = lsp_utils.common_on_attach,
		on_exit = lsp_utils.common_on_exit,
		on_init = lsp_utils.common_on_init,
		capabilities = lsp_utils.common_capabilities(),
		flags = { debounce_text_changes = 150 },
	}

	for server, opts in pairs(servers.configs) do
		if type(opts) == "function" then
			opts(options)
		else
			opts = vim.tbl_deep_extend("force", {}, options, opts or {})
			require("lspconfig")[server].setup(opts)
		end
	end

	require("config.lsp.null-ls").setup(options)
end

return M
