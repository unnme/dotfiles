---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local statusline = require("config.statusline")
    opts.sections.lualine_x = {
      function()
        return statusline.clients() or ""
      end,
    }
  end,
}
