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
          selection_chars = "ABCDEFG",
          filter_rules = {
            bo = {
              filetype = { "neo-tree-popup", "quickfix" },
              buftype = { "terminal", "quickfix", "nofile" },
            },
          },
          hint = "floating-big-letter",
          highlights = {
            statusline = {
              focused = {
                fg = "#ededed",
                bg = "#e35e4f",
                bold = true,
              },
              unfocused = {
                fg = "#ededed",
                bg = "#000000",
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
                bg = "#45475a",
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
          ["l"] = "open_with_window_picker",
          ["h"] = "close_node",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
          ["P"] = function(state)
            local node = state.tree:get_node()
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end,
        },
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
}
