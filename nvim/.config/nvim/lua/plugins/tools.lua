return {
  {
    "jackMort/ChatGPT.nvim",
    cmd = { "ChatGPTActAs", "ChatGPT" },
    opts = {},
  },

  -- {
  --   "max397574/colortils.nvim",
  --   cmd = "Colortils",
  --   config = function()
  --     require("colortils").setup({
  --       -- Register in which color codes will be copied
  --       register = "+",
  --       -- Preview for colors, if it contains `%s` this will be replaced with a hex color code of the color
  --       color_preview = "█ %s",
  --       -- The default in which colors should be saved
  --       -- This can be hex, hsl or rgb
  --       default_format = "hex",
  --       -- Border for the float
  --       border = "rounded",
  --       -- Some mappings which are used inside the tools
  --       mappings = {
  --         -- increment values
  --         increment = "l",
  --         -- decrement values
  --         decrement = "h",
  --         -- increment values with bigger steps
  --         increment_big = "L",
  --         -- decrement values with bigger steps
  --         decrement_big = "H",
  --         -- set values to the minimum
  --         min_value = "0",
  --         -- set values to the maximum
  --         max_value = "$",
  --         -- save the current color in the register specified above with the format specified above
  --         set_register_default_format = "<cr>",
  --         -- save the current color in the register specified above with a format you can choose
  --         set_register_cjoose_format = "g<cr>",
  --         -- replace the color under the cursor with the current color in the format specified above
  --         replace_default_format = "<m-cr>",
  --         -- replace the color under the cursor with the current color in a format you can choose
  --         replace_choose_format = "g<m-cr>",
  --         -- export the current color to a different tool
  --         export = "E",
  --         -- set the value to a certain number (done by just entering numbers)
  --         set_value = "c",
  --         -- toggle transparency
  --         transparency = "T",
  --         -- choose the background (for transparent colors)
  --         choose_background = "B",
  --       },
  --     })
  --   end,
  -- },

  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          names = false, -- "Name" codes like Blue or blue
          css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          -- Available modes for `mode`: foreground, background,  virtualtext
          mode = "background", -- Set the display mode.
          -- Available methods are false / true / "normal" / "lsp" / "both"
          -- True is same as normal
          tailwind = true, -- Enable tailwind colors
          -- parsers can contain values used in |user_default_options|
          sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
          virtualtext = "■",
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = false,
        },
        -- all the sub-options of filetypes apply to buftypes
        buftypes = {},
      })
    end,
  },
  {
    "ziontee113/color-picker.nvim",
    config = function()
      require("color-picker").setup()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = true },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}
