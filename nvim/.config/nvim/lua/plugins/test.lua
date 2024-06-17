return {
  { "nvim-neotest/neotest-plenary" },
  { "haydenmeade/neotest-jest" },
  { "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-jest", "neotest-vitest", "neotest-plenary", ["rustaceanvim.neotest"] = {} } },
    requires = { "haydenmeade/neotest-jest", "marilari88/neotest-vitest", "mrcjkb/rustaceanvim" },
  },
}
