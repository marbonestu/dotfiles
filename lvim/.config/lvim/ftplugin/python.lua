-- python
lvim.lang.python.formatters = {
  {
    exe = "black",
  },
}

lvim.lang.python.linters = {
  {
    exe = "flake8",
  },
}

if lvim.builtin.dap.active then
  local dap_install = require "dap-install"
  dap_install.config("python", {})
end
