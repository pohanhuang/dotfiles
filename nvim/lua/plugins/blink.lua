return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      trigger = { show_on_keyword = true, show_on_trigger_character = true },
      list = { debounce = 100 },
    },
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
