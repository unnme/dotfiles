-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local general = augroup("General", { clear = true })

autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File reloaded automatically", vim.log.levels.INFO, { title = "nvim" })
  end,
  group = general,
  desc = "Notify user when file is reloaded automatically",
})

autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
  group = general,
  desc = "Equalize window splits on terminal resize",
})

autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    local mode = vim.fn.mode()
    if mode:match("i") then
      vim.opt.hlsearch = false
    else
      vim.opt.hlsearch = true
    end
  end,
  group = general,
  desc = "Toggle search highlight visibility by mode",
})

autocmd("FileType", {
  pattern = { "gitcommit", "log" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  group = general,
  desc = "Enable wrap and spellcheck for writing filetypes",
})

autocmd("FileType", {
  pattern = { "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
  group = general,
  desc = "Enable wrap but disable spellcheck for plain text files",
})

autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
  group = general,
  desc = "Enable wrap but disable spellcheck for markdown",
})

autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- Disable LSP semantic tokens — treesitter handles highlighting
    local lsp_groups = vim.fn.getcompletion("@lsp", "highlight")
    for _, group in ipairs(lsp_groups) do
      vim.api.nvim_set_hl(0, group, {})
    end

    -- Show diagnostics for all project files, not just open buffers
    require("workspace-diagnostics").populate_workspace_diagnostics(client, vim.api.nvim_get_current_buf())
  end,
  desc = "Disable semantic tokens and populate workspace diagnostics on LSP attach",
})
