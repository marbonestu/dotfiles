local api = vim.api

-- shared
local function send_tmux_cmd(cmd)
  local stdout = vim.split(vim.fn.system("tmux " .. cmd), "\n")
  return stdout, vim.v.shell_error
end

local function get_pane_id()
  return send_tmux_cmd('display-message -p "#{pane_id}"')[1]
end

local function get_pane_current_path()
  return send_tmux_cmd('display-message -p "#{pane_current_path}"')[1]
end

local M = {}

-- move between tmux splits and neovim windows
local tmux_directions = { h = "L", j = "D", k = "U", l = "R" }

local function send_move_cmd(direction)
  send_tmux_cmd("selectp -" .. tmux_directions[direction])
end

function M.move(direction)
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

local function pane_is_valid()
  if not linked_pane_id then
    return false
  end

  local _, status = send_tmux_cmd("has-session -t " .. linked_pane_id)
  if status > 0 then
    return false
  end

  return true
end

local function send_raw_keys(keys)
  send_tmux_cmd(string.format("send-keys -t %s %s", linked_pane_id, keys))
end

local function send_keys(keys)
  send_raw_keys(string.format('"%s" Enter', keys))
end

function M.send_command(cmd, opts)
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

function M.send_last_command()
  M.send_command(last_cmd)
end

function M.clear_last_command()
  last_cmd = nil
end

function M.open_in_current_dir()
  local current_dir = vim.fn.expand("%:p:h")
  M.open_in_dir(current_dir)
end

function M.open_in_current_pwd()
  M.open_in_dir(vim.fn.getcwd())
end

function M.open_in_dir(path)
  if not pane_is_valid() then
    send_tmux_cmd("split-window -p 30")
    linked_pane_id = get_pane_id()
  else
    send_tmux_cmd("select-pane -t " .. linked_pane_id)
  end

  if not (path == get_pane_current_path()) then
    send_keys("cd " .. path)
  end
end

function M.kill()
  if not pane_is_valid() then
    return
  end

  send_tmux_cmd("kill-pane -t " .. linked_pane_id)
end

function M.run_file(filetype)
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
vim.keymap.set("n", "<Leader>tt", ":lua require'config.tmux'.open_in_current_pwd()<CR>", keyopts)

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
