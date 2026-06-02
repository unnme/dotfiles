local M = {}

M.clients = function()
  local buf = vim.api.nvim_get_current_buf()
  local names = {}
  local added = {}

  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if not added[c.name] then
      table.insert(names, c.name)
      added[c.name] = true
    end
  end

  local ok_lint, lint = pcall(require, "lint")
  if ok_lint and lint.linters_by_ft then
    local list = lint.linters_by_ft[vim.bo.filetype]
    if list then
      for _, l in ipairs(list) do
        if not added[l] then
          table.insert(names, l)
          added[l] = true
        end
      end
    end
  end

  local ok_conf, conform = pcall(require, "conform")
  if ok_conf and conform.list_formatters then
    for _, f in ipairs(conform.list_formatters(buf)) do
      if not added[f.name] then
        table.insert(names, f.name)
        added[f.name] = true
      end
    end
  end

  if #names == 0 then
    return ""
  end

  -- Show just "LSP" on narrow windows
  if vim.o.columns < 100 then
    return " LSP"
  end

  return " " .. table.concat(names, ", ")
end

return M
