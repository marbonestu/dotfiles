local api = vim.api

-- shared
local send_tmux_cmd = function(cmd)
  local stdout = vim.split(vim.fn.system("tmux " .. cmd), "\n")
  return stdout, vim.v.shell_error
end

local get_pane_id = function()
  return send_tmux_cmd('display-message -p "#{pane_id}"')[1]
end

local M = {}

-- move between tmux splits and neovim windows
local tmux_directions = { h = "L", j = "D", k = "U", l = "R" }

local send_move_cmd = function(direction)
  send_tmux_cmd("selectp -" .. tmux_directions[direction])
end

M.move = function(direction)
  local current_win = api.nvim_get_current_win()
  vim.cmd("wincmd " .. direction)

  if api.nvim_get_current_win() == current_win then
    send_move_cmd(direction)
  end
end

local keyopts = { silent = true }
vim.keymap.set("n", "<C-h>", ":lua require'config.tmux'.move('h')<CR>", keyopts)
vim.keymap.set("n", "<C-j>", ":lua require'config.tmux'.move('j')<CR>", keyopts)
vim.keymap.set("n", "<C-k>", ":lua require'config.tmux'.move('k')<CR>", keyopts)
vim.keymap.set("n", "<C-l>", ":lua require'config.tmux'.move('l')<CR>", keyopts)

-- send commands to linked tmux pane
local linked_pane_id, last_cmd

local pane_is_valid = function()
  if not linked_pane_id then
    return false
  end

  local _, status = send_tmux_cmd("has-session -t " .. linked_pane_id)
  if status > 0 then
    return false
  end

  return true
end

local send_raw_keys = function(keys)
  send_tmux_cmd(string.format("send-keys -t %s %s", linked_pane_id, keys))
end

local send_keys = function(keys)
  send_raw_keys(string.format('"%s" Enter', keys))
end

M.send_command = function(cmd, opts)
  cmd = cmd or vim.fn.input("command: ", "", "shellcmd")
  if not cmd or cmd == "" then
    return
  end

  if not pane_is_valid() then
    local nvim_pane_id = get_pane_id()

    send_tmux_cmd("split-window -p 30")
    linked_pane_id = get_pane_id()

    if not opts.focus then
      send_tmux_cmd("select-pane -t " .. nvim_pane_id)
    end
  else
    send_raw_keys("C-c")
  end

  send_keys(cmd)
  last_cmd = cmd
end

M.send_last_command = function()
  M.send_command(last_cmd)
end

M.clear_last_command = function()
  last_cmd = nil
end

M.open_in_current_dir = function()
  local current_dir = vim.fn.expand("%:p:h")

  if not pane_is_valid() then
    send_tmux_cmd("split-window -p 30")
    linked_pane_id = get_pane_id()
  else
    send_tmux_cmd("select-pane -t " .. linked_pane_id)
  end

  send_keys("cd " .. current_dir)
end

M.kill = function()
  if not pane_is_valid() then
    return
  end

  send_tmux_cmd("kill-pane -t " .. linked_pane_id)
end

M.run_file = function(filetype)
  filetype = filetype or vim.bo.filetype
  local cmd
  if filetype == "javascript" then
    cmd = "node"
  elseif filetype == "lua" then
    cmd = "lua"
  elseif filetype == "python" then
    cmd = "python"
  end
  assert(cmd, "no command found for filetype " .. filetype)

  M.send_command(cmd .. " " .. api.nvim_buf_get_name(0))
end


vim.keymap.set("n", "<Leader>tn", ":lua require'config.tmux'.send_command()<CR>", keyopts)
vim.keymap.set("n", "<Leader>td", ":lua require'config.tmux'.open_in_current_dir()<CR>", keyopts)
-- vim.keymap.set("n", "<Leader>tt", ":lua require'config.tmux'.send_last_command()<CR>", keyopts)
-- vim.keymap.set("n", "<Leader>tc", ":lua require'config.tmux'.clear_last_command()<CR>", keyopts)
-- vim.keymap.set("n", "<Leader>tr", ":lua require'config.tmux'.run_file()<CR>", keyopts)

-- automatically kill pane on exit
api.nvim_create_autocmd("VimLeave", {
  callback = M.kill,
})

-- -- testing wrappers
-- local root_patterns = {
--     typescript = { "package.json" },
--     typescriptreact = { "package.json" },
-- }

-- local root_cache = {}
-- setmetatable(root_cache, {
--     __index = function(cache, bufnr)
--         local root = require("lspconfig").util.root_pattern(unpack(root_patterns[vim.bo[bufnr].filetype]))(
--             api.nvim_buf_get_name(bufnr)
--         )
--         rawset(cache, bufnr, root or false)
--         return root
--     end,
-- })

-- local test_commands = {
--     file = {
--         lua = "FILE=%s make test-file",
--         typescript = "npm run test -- %s",
--         typescriptreact = "npm run test -- %s",
--     },
--     suite = {
--         lua = "make test",
--         typescript = "npm run test",
--         typescriptreact = "npm run test",
--     },
-- }

-- M.test = function()
--     local test_command = test_commands.file[vim.bo.filetype]
--     assert(test_command, "no test command found for filetype " .. vim.bo.filetype)

--     if root_patterns[vim.bo.filetype] then
--         local root = root_cache[api.nvim_get_current_buf()]
--         if root then
--             M.send_command(string.format("cd %s", root))
--         end
--     end

--     M.send_command(string.format(test_command, api.nvim_buf_get_name(0)))
-- end

-- M.test_suite = function()
--     M.send_command(test_commands.suite[vim.bo.filetype])
-- end

-- u.nmap("<Leader>tf", ":lua require'config.tmux'.test()<CR>")
-- u.nmap("<Leader>ts", ":lua require'config.tmux'.test_suite()<CR>")

return M
