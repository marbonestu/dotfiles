local function getTelescopeOpts(state, path)
  local node = state.tree:get_node()
  local is_folder = node.type == "directory"
  local basedir = is_folder and path or vim.fn.fnamemodify(path, ":h")
  return {
    cwd = basedir,
    search_dirs = { basedir },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require("telescope.actions.state")
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if filename == nil then
          filename = selection[1]
        end
        -- any way to open the file without triggering auto-close event of neo-tree?
        vim.cmd("e " .. vim.fn.fnameescape(filename))
      end)
      return true
    end,
  }
end

local function open_in_terminal(state, path)
  local node = state.tree:get_node()
  local is_folder = node.type == "directory"
  local basedir = is_folder and path or vim.fn.fnamemodify(path, ":h")
  require("tmux").open_in_dir(basedir)
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").get_root() })
        end,
        desc = "Explorer NeoTree (root dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>?",
        function()
          require("neo-tree.command").execute({ toggle = false })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    dependencies = {
      "mrbjarksen/neo-tree-diagnostics.nvim",
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
    },
    opts = {
      window = {
        mappings = {
          ["<space>"] = "none",
          ["s"] = "none",
          ["/"] = "none",
          ["l"] = "open_fn",
          ["h"] = "close_node",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
          ["t"] = "open_in_terminal",
          ["gtf"] = "telescope_find",
          ["gtg"] = "telescope_grep",
          ["P"] = function(state)
            local node = state.tree:get_node()
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end,
        },
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

        open_in_terminal = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          open_in_terminal(state, path)
        end,
        telescope_find = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require("telescope.builtin").find_files(getTelescopeOpts(state, path))
        end,
        telescope_grep = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require("telescope.builtin").live_grep(getTelescopeOpts(state, path))
        end,
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_gitignored = false,
        },
      },
    },
  },

  {
    "telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-dap.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      { "debugloop/telescope-undo.nvim" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 10,
      },
      extensions = {
        undo = {
          use_delta = true,
          side_by_side = true,
          layout_strategy = "vertical",
          layout_config = {
            preview_height = 0.4,
          },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- telescope.load_extension("dap")
      -- telescope.load_extension("undo")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {

      signs = {
        add = { hl = "GitSignsAdd", text = "▍", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        change = {
          hl = "GitSignsChange",
          text = "▍",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
        delete = {
          hl = "GitSignsDelete",
          text = "▸",
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn",
        },
        topdelete = {
          hl = "GitSignsDelete",
          text = "▾",
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn",
        },
        changedelete = {
          hl = "GitSignsChange",
          text = "▍",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
      },

      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "<leader>gj", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        map("n", "<leader>gk", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        -- Actions
        map({ "n", "v" }, "<leader>g", ":Gitsigns stage_hunk<CR>")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>gS", gs.stage_buffer)
        map("n", "<leader>gu", gs.undo_stage_hunk)
        map("n", "<leader>gR", gs.reset_buffer)
        map("n", "<leader>gp", gs.preview_hunk)
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end)
        map("n", "<leader>gl", gs.blame_line)
        map("n", "<leader>gL", "<cmd>G blame<CR>")
        map("n", "<leader>gd", gs.diffthis)
        map("n", "<leader>gD", function()
          gs.diffthis("~")
        end)
        map("n", "<leader>gd", gs.toggle_deleted)

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["gz"] = { name = "+surround" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
      },
    },
  },
  { "folke/noice.nvim", enabled = false },
}
