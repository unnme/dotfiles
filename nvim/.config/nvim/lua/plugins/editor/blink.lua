---@type LazySpec
return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      -- Tab/Shift-Tab walk the completion menu; fall back to snippet jumps, then a real Tab.
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
  },
}
