return {
  {
    "Mofiqul/vscode.nvim",
    name = "vscode",
    config = function()
      require("vscode").load()
      vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "Normal" })
      vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { link = "Normal" })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
