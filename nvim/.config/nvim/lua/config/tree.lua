local M = {}

function M.setup()
  local setup = {
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    open_on_setup_file = false,
    sort_by = "name",
    ignore_buffer_on_setup = false,
    ignore_ft_on_setup = {
      "startify",
      "dashboard",
      "alpha",
    },
    auto_reload_on_write = true,
    hijack_unnamed_buffer_when_opening = false,
    hijack_directories = {
      enable = true,
      auto_open = true,
    },
    open_on_tab = false,
    hijack_cursor = false,
    diagnostics = {
      enable = true,
      show_on_dirs = false,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = "",
      },
    },
    update_cwd = false,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_cwd = true,
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
      height = 30,
      hide_root_folder = false,
      side = "left",
      preserve_window_proportions = false,
      mappings = {
        custom_only = false,
        list = {},
      },
      number = false,
      relativenumber = false,
      signcolumn = "yes",
    },
    renderer = {
      highlight_git = true,
      root_folder_modifier = ":t",
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
        }
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
    M.start_telescope "find_files"
  end

  local function telescope_live_grep(_)
    M.start_telescope "live_grep"
  end

  setup.view.mappings.list = {
    { key = { "l", "<CR>", "o" }, action = "edit", mode = "n" },
    { key = "h", action = "close_node" },
    { key = "v", action = "vsplit" },
    { key = "C", action = "cd" },
    { key = "<C-e>", action = "" },
    { key = "<C-y>", action = "" },
    { key = "gtf", action = "telescope_find_files", action_cb = telescope_find_files },
    { key = "gtg", action = "telescope_live_grep", action_cb = telescope_live_grep },
    { key = "t", action = "open_in_terminal", action_cb = M.open_in_terminal },
  }

  require("nvim-tree").setup(setup)

  vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>')
  vim.keymap.set('n', '<leader>?', '<cmd>NvimTreeFindFile<CR>')
end

function M.start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode] {
    cwd = basedir,
  }
end

function M.open_in_terminal()
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("config.tmux").open_in_dir(basedir)
end

return M
