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
          ["gb"] = "open_in_browser",
          ["gtg"] = "telescope_grep",
          ["Y"] = function(state)
            local node = state.tree:get_node()
            vim.fn.setreg("+", node:get_id())
            vim.notify("Path copied to clipboard!")
          end,
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

  -- {
  --   "telescope.nvim",
  --   dependencies = {
  --     { "nvim-telescope/telescope-dap.nvim" },
  --     {
  --       "nvim-telescope/telescope-fzf-native.nvim",
  --       build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  --     },
  --     { "debugloop/telescope-undo.nvim" },
  --   },
  --   opts = {
  --     defaults = {
  --       layout_strategy = "horizontal",
  --       layout_config = { prompt_position = "top" },
  --       sorting_strategy = "ascending",
  --       winblend = 10,
  --     },
  --     extensions = {
  --       undo = {
  --         use_delta = true,
  --         side_by_side = true,
  --         layout_strategy = "vertical",
  --         layout_config = {
  --           preview_height = 0.4,
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     local telescope = require("telescope")
  --     telescope.setup(opts)
  --     -- telescope.load_extension("dap")
  --     -- telescope.load_extension("undo")
  --   end,
  -- },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
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
        end, "Next hunk")

        map("n", "<leader>gk", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, "Prev hunk")

        map("n", "<leader>gb", function()
          local buffer_path = vim.fn.expand("%:p")
          local line_number = vim.fn.line(".")
          require("git").open_file_in_browser(buffer_path, line_number)
        end, "Open file in browser")

        map("n", "<leader>gB", function()
          local buffer_path = vim.fn.expand("%:p")
          local line_number = vim.fn.line(".")
          require("git").open_file_in_browser_in_line(buffer_path, line_number)
        end, "Open file and line in browser ")
        map("n", "<leader>g.", function()
          local buffer_path = vim.fn.expand("%:p")
          local line_number = vim.fn.line(".")
          require("git").open_file_in_browser_branch(buffer_path, line_number)
        end, "Open file/line and branch in browser")
        -- -- Actions
        -- map("n", "<leader>gd", gs.diffthis)
        -- map("n", "<leader>gD", function()
        --   gs.diffthis("~")
        -- end)
        -- map("n", "<leader>gd", gs.toggle_deleted)
        --
        -- map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        -- map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", function()
          gs.stage_buffer()
        end, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghB", function()
          gs.blame()
        end, "Blame Buffer")
        -- map("n", "<leader>ghd", gs.diffthis, "Diff This")
        -- map("n", "<leader>ghD", function()
        --   gs.diffthis("~")
        -- end, "Diff This ~")
        -- map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
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
        -- ["<leader>gh"] = { name = "+hunks" },
        -- ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
      },
    },
  },
  { "folke/noice.nvim", enabled = false },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "<leader>S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  {
    "folke/trouble.nvim",
    opts = {
      modes = {
        symbols = {
          win = { size = { width = 50 } },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics focus=true<cr>", desc = "Diagnostics (Trouble)" },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics filter.buf=0 focus=true<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      { "<leader>cs", "<cmd>Trouble symbols focus=true<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>cS",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP references/definitions/... (Trouble)",
      },
    },
  },
}
