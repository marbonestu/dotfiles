local paths = require("paths")

local M = {}

-- Function to find the project root path based on Git
function M.find_git_root()
  local result = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")
  if vim.v.shell_error == 0 and #result > 0 then
    return result[1]
  else
    return nil
  end
end

function M.open_file_in_browser(abs_path, line_number)
  local line_number_str = line_number and (":" .. line_number) or ""
  local absolute_git_path = paths.path_relative(abs_path, M.find_git_root())
  local process = io.popen("gh browse " .. absolute_git_path .. line_number_str)
  process:close()
end

-- -- Get the project root path
-- local project_root = M.find_git_root()
--
-- -- Print the project root path (you can replace this with any other use)
-- if project_root then
--   print("Project Root: " .. project_root)
-- else
--   print("Project Root not found.")
-- end

return M
