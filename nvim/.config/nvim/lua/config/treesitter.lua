require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "css",
        "javascript",
        "typescript",
        "json",
        "jsonc",
        "lua",
        "make",
        "markdown",
        "scss",
        "toml",
        "tsx",
        "yaml",
    },
    highlight = { enable = true },
    -- plugins
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    textsubjects = {
        enable = true,
        keymaps = { ["."] = "textsubjects-smart" },
    },
    autotag = { enable = true },
})
