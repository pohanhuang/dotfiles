return {
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        terminal = {
          position = "right",
        },
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            exclude = { ".git" },
            win = {
              list = {
                keys = {
                  ["<c-t>"] = false,
                },
              },
            },
          },
        },
      },
    },
  },
}
