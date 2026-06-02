---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      powershell_es = {
        bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
        settings = {
          powershell = {
            scriptAnalysis = {
              enable = true,
              settingsPath = vim.fn.stdpath("config") .. "/lsp/PSScriptAnalyzerSettings.psd1",
            },
          },
        },
      },
    },
  },
}
