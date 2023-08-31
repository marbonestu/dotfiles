local M = {}

function M.setup()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      "bash",
      "css",
      "java",
      "javascript",
      "typescript",
      "python",
      "rust",
      "hcl",
      "json",
      "jsonc",
      "lua",
      "make",
      "markdown",
      "scss",
      "toml",
      "tsx",
      "yaml",
      "go",
    },

    highlight = {
      enable = true, -- false will disable the whole extension
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },
    indent = {
      enable = true,
    },
    autotag = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aC"] = "@class.outer",
          ["iC"] = "@class.inner",
          ["ac"] = "@conditional.outer",
          ["ic"] = "@conditional.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["is"] = "@statement.inner",
          ["as"] = "@statement.outer",
          ["am"] = "@call.outer",
          ["im"] = "@call.inner",
          ["ad"] = "@comment.outer",
          ["id"] = "@comment.inner",
          ["ia"] = "@parameter.inner",
          ["aa"] = "@parameter.outer",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
          ["]a"] = "@parameter.inner",
          ["]b"] = "@block.inner",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
          ["[a"] = "@parameter.inner",
          ["[b"] = "@block.inner",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
          ["[A"] = "@parameter.inner",
        },
      },
    },
  }

  -- Smithy parser
  local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  parser_config.smithy = {
    install_info = {
      url = "https://github.com/indoorvivants/tree-sitter-smithy", -- local path or git repo
      files = { "src/parser.c" },
      -- optional entries:
      branch = "main", -- default branch in case of git repo if different from master
      generate_requires_npm = true, -- if stand-alone parser without npm dependencies
      requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
    },
    filetype = "smithy" -- if filetype does not agrees with parser name
  }
end

return M
