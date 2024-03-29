local M = {}

function M.setup()
	local setup = {
		disable_netrw = true,
		hijack_netrw = true,
		-- open_on_setup_file = false,
		sort_by = "name",
		-- ignore_buffer_on_setup = false,
		-- ignore_ft_on_setup = {
		--   "startify",
		--   "dashboard",
		--   "alpha",
		-- },
		auto_reload_on_write = true,
		hijack_unnamed_buffer_when_opening = false,
		hijack_directories = {
			enable = true,
			auto_open = true,
		},
		open_on_tab = false,
		hijack_cursor = false,
		diagnostics = {
			enable = false,
			show_on_dirs = false,
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		update_cwd = false,
		respect_buf_cwd = false,
		update_focused_file = {
			enable = true,
			update_cwd = false,
		},
		system_open = {
			cmd = nil,
			args = {},
		},
		git = {
			enable = true,
			ignore = false,
			timeout = 200,
		},
		view = {
			width = 50,
			hide_root_folder = false,
			side = "left",
			preserve_window_proportions = false,
			number = false,
			relativenumber = false,
			signcolumn = "yes",
		},
		renderer = {
			highlight_git = true,
			root_folder_modifier = ":t",
			group_empty = true,
			indent_markers = {
				enable = false,
				icons = {
					corner = "└ ",
					edge = "│ ",
					none = "  ",
				},
			},
			icons = {
				webdev_colors = true,
				show = {
					file = true,
					folder = true,
					git = false,
					folder_arrow = true,
				},
				glyphs = {
					default = "",
					symlink = "",
					git = {
						unstaged = "",
						staged = "S",
						unmerged = "",
						renamed = "➜",
						deleted = "",
						untracked = "U",
						ignored = "◌",
					},
					folder = {
						default = "",
						open = "",
						empty = "",
						empty_open = "",
						symlink = "",
					},
				},
			},
		},
		filters = {
			dotfiles = false,
			-- custom = { "node_modules", "\\.cache" },
			exclude = {},
		},
		trash = {
			cmd = "trash",
			require_confirm = true,
		},
	}

	local function telescope_find_files(_)
		M.start_telescope("files")
	end

	local function telescope_live_grep(_)
		M.start_telescope("live_grep")
	end

	local function my_on_attach(bufnr)
		local api = require("nvim-tree.api")

		local function edit_or_open()
			local node = api.tree.get_node_under_cursor()

			if node.nodes ~= nil then
				-- expand or collapse folder
				api.node.open.edit()
			else
				-- open file
				api.node.open.edit()
				-- Close the tree if file was opened
				-- api.tree.close()
			end
		end

		local function opts(desc)
			return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
		end

		-- default mappings
		api.config.mappings.default_on_attach(bufnr)

		-- custom mappings
		vim.keymap.set("n", "l", edit_or_open, opts("Up"))
		vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Help"))
		vim.keymap.set("n", "gtf", telescope_find_files, opts("Help"))
		vim.keymap.set("n", "gtg", telescope_live_grep, opts("Help"))
		vim.keymap.set("n", "t", M.open_in_terminal, opts("Help"))
	end

	setup.on_attach = my_on_attach

	-- setup.view.mappings.list = {
	-- 	{ key = "l", action = "edit", mode = "n" },
	-- 	{ key = "h", action = "close_node" },
	-- 	{ key = "v", action = "vsplit" },
	-- 	{ key = "C", action = "cd" },
	-- 	{ key = "<C-e>", action = "" },
	-- 	{ key = "<C-y>", action = "" },
	-- 	{ key = "gtf", action = "telescope_find_files", action_cb = telescope_find_files },
	-- 	{ key = "gtg", action = "fzf_live_grep", action_cb = telescope_live_grep },
	-- 	{ key = "t", action = "open_in_terminal", action_cb = M.open_in_terminal },
	-- }

	require("nvim-tree").setup(setup)

	vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
	vim.keymap.set("n", "<leader>?", "<cmd>NvimTreeFocus<CR>")
end

function M.start_telescope(telescope_mode)
	local node = require("nvim-tree.lib").get_node_at_cursor()
	local abspath = node.link_to or node.absolute_path
	local is_folder = node.open ~= nil
	local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
	require("fzf-lua")[telescope_mode]({
		cwd = basedir,
	})
end

function M.open_in_terminal()
	local node = require("nvim-tree.lib").get_node_at_cursor()
	local abspath = node.link_to or node.absolute_path
	local is_folder = node.open ~= nil
	local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
	require("config.tmux").open_in_dir(basedir)
end

return M
