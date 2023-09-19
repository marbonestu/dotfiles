local M = {}
local path_separator = package.config:sub(1, 1)

function M.path_add_trailing(path)
  if path:sub(-1) == path_separator then
    return path
  end

  return path .. path_separator
end
function M.path_relative(path, relative_to)
  local _, r = path:find(M.path_add_trailing(relative_to), 1, true)
  local p = path
  if r then
    -- take the relative path starting after '/'
    -- if somehow given a completely matching path,
    -- returns ""
    p = path:sub(r + 1)
  end
  return p
end

return M
