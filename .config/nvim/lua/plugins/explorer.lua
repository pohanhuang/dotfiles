return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true, -- 顯示 dotfiles
            ignored = true, -- 顯示 gitignore 的檔案；若不想顯示可改 false
            exclude = { ".git" },
          },
        },
      },
    },
  },
}
