-- jdtls' bundled wrapper shells out to `java` to check the version. If nvim
-- was started without PATH containing homebrew's openjdk (e.g. non-interactive
-- shell, since it's only added in .zshrc), it falls back to the system java
-- stub and jdtls fails to start. JAVA_HOME makes the wrapper use this java
-- regardless of PATH.
vim.env.JAVA_HOME = vim.env.JAVA_HOME or "/opt/homebrew/opt/openjdk"

---@type LazySpec
return {
  "mfussenegger/nvim-jdtls",
  opts = {
    -- workspace-diagnostics.nvim needs client.config.filetypes to populate
    -- diagnostics for jdtls; nvim-jdtls doesn't set it by default.
    jdtls = { filetypes = { "java" } },
  },
}
