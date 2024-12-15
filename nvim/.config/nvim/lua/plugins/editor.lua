local function open_in_terminal(state, path)
  local node = state.tree:get_node()
  local is_folder = node.type == "directory"
  local basedir = is_folder and path or vim.fn.fnamemodify(path, ":h")
  require("tmux").open_in_dir(basedir)
end

return {
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>?",
        function()
          require("neo-tree.command").execute({ toggle = false })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
    },
    dependencies = {},
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end,
      })
    end,
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      window = {
        mappings = {
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
          ["l"] = {
            function(state)
              local node = state.tree:get_node()
              if require("neo-tree.utils").is_expandable(node) then
                state.commands["toggle_node"](state)
              else
                local windows = vim.api.nvim_list_wins()
                if #windows > 1 then
                  state.commands["open_with_window_picker"](state)
                else
                  state.commands["open"](state)
                  vim.cmd("Neotree reveal")
                end
              end
            end,
          },
          ["h"] = "close_node",
          ["t"] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            open_in_terminal(state, path)
          end,
          ["gtf"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()

              local is_folder = node.type == "directory"
              local basedir = is_folder and path or vim.fn.fnamemodify(path, ":h")
              require("fzf-lua").files({
                cwd = basedir,
              })
            end,
          },
          ["gb"] = "open_in_browser",
          ["gtg"] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            local is_folder = node.type == "directory"
            local basedir = is_folder and path or vim.fn.fnamemodify(path, ":h")
            require("fzf-lua").live_grep({
              cwd = basedir,
            })
          end,
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
        commands = {
          open_fn = function(state)
            local node = state.tree:get_node()
            if require("neo-tree.utils").is_expandable(node) then
              state.commands["toggle_node"](state)
            else
              local windows = vim.api.nvim_list_wins()
              if #windows > 1 then
                state.commands["open_with_window_picker"](state)
              else
                state.commands["open"](state)
                vim.cmd("Neotree reveal")
              end
            end
          end,
          open_in_browser = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("git").open_file_in_browser(path)
          end,
          open_in_terminal = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            open_in_terminal(state, path)
          end,
          fzf_find = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("fzf-lua").files({
              cwd = path,
            })
          end,
          fzf_grep = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("fzf-lua").live_grep({
              cwd = path,
            })
          end,
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },

  {
    "s1n7ax/nvim-window-picker",
    opts = {
      use_winbar = "smart",
      autoselect_one = true,
      include_current = false,
      selection_chars = "ABCD",
      filter_rules = {
        bo = {
          filetype = { "neo-tree-popup", "quickfix" },
          buftype = { "terminal", "quickfix", "nofile" },
        },
      },
      picker_config = {
        statusline_winbar_picker = {
          -- You can change the display string in status bar.
          -- It supports '%' printf style. Such as `return char .. ': %f'` to display
          -- buffer file path. See :h 'stl' for details.
          selection_display = function(char, windowid)
            return "%=" .. char .. "%="
          end,

          -- whether you want to use winbar instead of the statusline
          -- "always" means to always use winbar,
          -- "never" means to never use winbar
          -- "smart" means to use winbar if cmdheight=0 and statusline if cmdheight > 0
          use_winbar = "always", -- "always" | "never" | "smart"
        },

        floating_big_letter = {
          -- window picker plugin provides bunch of big letter fonts
          -- fonts will be lazy loaded as they are being requested
          -- additionally, user can pass in a table of fonts in to font
          -- property to use instead

          font = "ansi-shadow", -- ansi-shadow |
        },
      },
      hint = "statusline-winbar",
      highlights = {
        statusline = {
          focused = {
            fg = "#ededed",
            bg = "#e35e4f",
            bold = true,
          },
          unfocused = {
            fg = "#cdd6f4",
            bg = "#0064a3",
            bold = true,
          },
        },
        winbar = {
          focused = {
            fg = "#ededed",
            bg = "#e35e4f",
            bold = true,
          },
          unfocused = {
            fg = "#cdd6f4",
            bg = "#0064a3",
            bold = true,
          },
        },
      },
    },
  },
}
