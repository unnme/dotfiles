---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      exclude = { "**/node_modules/**", "**/.venv/**" },
    },
  },
}
