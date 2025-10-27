return {
  {
    "nvim-mini/mini.pairs",
    opts = {
      modes = { insert = false, command = false, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[<[%w%%%'%[%"%.%`%$]]=],
    },
  },
}
