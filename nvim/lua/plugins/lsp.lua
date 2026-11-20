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
      setup = {
        yamlls = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      },
    },
  },
}
