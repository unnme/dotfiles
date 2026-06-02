---@type LazySpec
return {
  "XXiaoA/atone.nvim",
  cmd = "Atone",
  opts = {
    layout = {
      direction = "right",
    },
  },
  keys = {
    {
      "<leader>bu",
      "<cmd>Atone toggle<cr>",
      desc = "Undo Tree",
      silent = true,
    },
  },
}
