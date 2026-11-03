return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    -- Toggle is registered at startup (not in `config`), otherwise it would only
    -- show up in the <leader>u menu after the first InsertEnter loads the plugin.
    init = function()
      -- `init` runs before snacks.nvim is loaded, so wait for VeryLazy.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          Snacks.toggle({
            name = "Supermaven",
            icon = { enabled = "\u{F06A9} ", disabled = "\u{F16A7} " },
            color = { enabled = "green", disabled = "yellow" },
            get = function()
              return package.loaded["supermaven-nvim"] ~= nil and require("supermaven-nvim.api").is_running()
            end,
            set = function(state)
              local api = require("supermaven-nvim.api")
              if state then
                api.start()
              else
                api.stop()
              end
            end,
          }):map("<leader>uM")
        end,
      })
    end,
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
      -- Off by default; enable with <leader>uM
      require("supermaven-nvim.api").stop()
    end,
    opts = {
      keymaps = {
        accept_suggestion = "<C-l>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { java = true, TelescopePrompt = true, ["neo-tree"] = true },
      log_level = "off",
    },
  },
}
