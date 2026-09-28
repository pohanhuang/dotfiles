return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = false, shadow = false },
              staticcheck = false,
            },
          },
        },
      },
    },
  },
}
