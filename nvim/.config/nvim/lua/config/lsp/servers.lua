local M = {}
local utils = require("utils")

M.configs = {
	ansiblels = {},
	bashls = {},
	clangd = {},
	cssls = {},
	dockerls = {},
	tsserver = function(options)
		local settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		}

		-- options.on_attach = function(client, bufnr)
		-- 	options.on_attach(client, bufnr)
		-- vim.keymap.set('n', '<leader>lI', ":TypescriptAddMissingImports")
		-- end

		require("typescript").setup({ server = options, settings = settings })
	end,
	-- svelte = {},
	eslint = {},
	html = {},
	jsonls = {
		settings = {
			json = {
				format = {
					enable = true,
				},
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	},
	gopls = {},
	marksman = {},
	pyright = {},
	terraformls = {},
	solargraph = {},

	rust_analyzer = function(options)
		require("rust-tools").setup({
			tools = {
				executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
				reload_workspace_from_cargo_toml = true,
				runnables = {
					use_telescope = true,
				},
				inlay_hints = {
					auto = true,
					only_current_line = false,
					show_parameter_hints = false,
					parameter_hints_prefix = "<-",
					other_hints_prefix = "=>",
					max_len_align = false,
					max_len_align_padding = 1,
					right_align = false,
					right_align_padding = 7,
					highlight = "Comment",
				},
				hover_actions = {
					border = "rounded",
				},
				on_initialized = function()
					vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
						pattern = { "*.rs" },
						callback = function()
							local _, _ = pcall(vim.lsp.codelens.refresh)
						end,
					})
				end,
			},
			-- dap = {
				-- adapter = require("rust-tools.dap").get_codelldb_adapter(
					-- "codelldb",
					-- require("mason-registry").get_package("codelldb"):get_install_path()
					-- 	.. "/extension/lldb/lib/liblldb.dylib"
				-- ),
			-- },
			server = vim.tbl_deep_extend("force", options, {
				settings = {
					["rust-analyzer"] = {
						lens = {
							enable = true,
						},
						checkOnSave = {
							enable = true,
							command = "clippy",
						},
					},
				},
			}),
		})
	end,

	yamlls = {
		settings = {
			yaml = {
				hover = true,
				completion = true,
				validate = true,
				schemas = require("schemastore").json.schemas(),
			},
		},
	},
	lua_ls = function(options)
		require("neodev").setup({
			debug = true,
			experimental = {
				pathStrict = true,
			},
			library = {
				runtime = "~/neovim/runtime/",
			},
		})
		require("lspconfig")["lua_ls"].setup(vim.tbl_deep_extend("force", options or {}, {
			-- cmd = { "/home/folke/projects/lua-language-server/bin/lua-language-server" },
			single_file_support = true,
			settings = {
				Lua = {
					workspace = {
						checkThirdParty = false,
					},
					completion = {
						workspaceWord = true,
						callSnippet = "Both",
					},
					misc = {
						parameters = {
							"--log-level=trace",
						},
					},
					diagnostics = {
						-- enable = false,
						groupSeverity = {
							strong = "Warning",
							strict = "Warning",
						},
						groupFileStatus = {
							["ambiguity"] = "Opened",
							["await"] = "Opened",
							["codestyle"] = "None",
							["duplicate"] = "Opened",
							["global"] = "Opened",
							["luadoc"] = "Opened",
							["redefined"] = "Opened",
							["strict"] = "Opened",
							["strong"] = "Opened",
							["type-check"] = "Opened",
							["unbalanced"] = "Opened",
							["unused"] = "Opened",
						},
						unusedLocalExclude = { "_*" },
					},
					format = {
						enable = false,
						defaultConfig = {
							indent_style = "space",
							indent_size = "2",
							continuation_indent_size = "2",
						},
					},
				},
			},
		}))
	end,
	-- teal_ls = {},
	-- tailwindcss = {},
}

M.get_server_keys = function()
	return utils.get_keys(M.configs)
end

return M
