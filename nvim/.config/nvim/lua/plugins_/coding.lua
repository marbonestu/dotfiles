return {
  {
    "nvim-cmp",
    opts = function(_, opts)
      opts.window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:Pmenu",
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:Pmenu",
        },
      }
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "copilot", group_index = 2 } }))
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    -- Not all LSP servers add brackets when completing a function.
    -- To better deal with this, LazyVim adds a custom option to cmp,
    -- that you can configure. For example:
    --
    -- ```lua
    -- opts = {
    --   auto_brackets = { "python" }
    -- }
    -- ```
    opts = {
      formating = {
        format = function(entry, item)
          local icons = LazyVim.config.icons.kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end
          return item
        end,
      },
    },
    main = "lazyvim.util.cmp",
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  { "echasnovski/mini.pairs", enabled = false },
  { "echasnovski/mini.surround", enabled = false },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {}, -- this is equalent to setup({}) function
  },

  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load("../snippets")
    end,
  },
}
