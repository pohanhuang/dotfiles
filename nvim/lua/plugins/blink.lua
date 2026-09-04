return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<M-Esc>"] = { "show", "fallback" },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
    },
    cmdline = {
      keymap = {
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
      },
    },
  },
}
