-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.o.relativenumber = false

-- phpactor has no diagnosticProvider capability (no error/syntax checking at
-- all); intelephense actually reports errors, which is the point of the extra.
vim.g.lazyvim_php_lsp = "intelephense"
