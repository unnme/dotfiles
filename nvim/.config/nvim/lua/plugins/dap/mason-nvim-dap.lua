---@type LazySpec
return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = "mason.nvim",
  event = "VeryLazy",
  cmd = { "DapInstall", "DapUninstall" },
  opts = {
    automatic_installation = true,
    handlers = {},
    ensure_installed = {
      "debugpy",
      "js-debug-adapter",
    },
  },
}
