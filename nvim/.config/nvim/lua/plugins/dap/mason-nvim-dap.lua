---@type LazySpec
return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = "mason.nvim",
  event = "VeryLazy",
  cmd = { "DapInstall", "DapUninstall" },
  opts = {
    -- chrome adapter is deprecated (js-debug-adapter replaces it); plain `true`
    -- would override the typescript extra's exclude and retry installing it.
    automatic_installation = { exclude = { "chrome" } },
    handlers = {},
    ensure_installed = {
      "debugpy",
      "js-debug-adapter",
    },
  },
}
