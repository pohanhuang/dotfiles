return {
  "folke/noice.nvim",
  opts = {
    views = {
      cmdline_popup = {
        win_options = {},
      },
    },
  },
  keys = {
    -- cmdline popup 裡用 arrow key 移動
    {
      "<Down>",
      function()
        if require("noice").redirect then end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
      end,
      mode = "c",
    },
    {
      "<Up>",
      function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
      end,
      mode = "c",
    },
  },
}
