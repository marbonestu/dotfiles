return {
  {
    "3rd/image.nvim",
    ft = { "markdown", "norg" },
    opts = {
      backend = "kitty",
      kitty_method = "normal",
      integrations = {
        markdown = { enabled = true },
      },
      tmux_show_only_in_active_window = true,
    },
    init = function()
      -- Forward TERM_PROGRAM from tmux environment so the backend
      -- can detect Ghostty/Kitty as the underlying terminal.
      if os.getenv("TMUX") then
        local handle = io.popen("tmux show-environment TERM_PROGRAM 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          local val = result:match("TERM_PROGRAM=(.*)")
          if val then
            vim.env.TERM_PROGRAM = vim.trim(val)
          end
        end
      end
    end,
  },
}
