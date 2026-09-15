return {
  "pablopunk/pi.nvim",
  opts = {
    provider = "anthropic",
    model = "claude-sonnet-4-6",
  },
  keys = {
    { "<leader>ai", ":PiAsk<CR>",          desc = "Ask pi" },
    { "<leader>ai", ":PiAskSelection<CR>", mode = "v",     desc = "Ask pi (selection)" },
  },
}
