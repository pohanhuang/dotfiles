return {
  "olimorris/codecompanion.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  opts = {
    adapters = {
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {})
        end,
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = { auth_method = "chat-gpt" },
          })
        end,
      },
    },
    interactions = {
      chat = { adapter = "claude_code" },
    },
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Chat (Claude)" },
    { "<leader>ao", "<cmd>CodeCompanionChat codex<cr>",  desc = "Chat (Codex)" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>",     desc = "AI Actions" },
    { "ga",         "<cmd>CodeCompanionChat Add<cr>",    mode = "v", desc = "Add to chat" },
  },
  init = function()
    require("which-key").add({
      { "<leader>a", group = "CodeCompanion" },
    })
  end,
}
