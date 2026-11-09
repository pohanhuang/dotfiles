-- Herdr counterpart of vim-tmux-navigator: only loaded inside herdr.
-- Herdr side is the local.vim-navigator plugin (see .bashrc.d/herdr.sh).
return {
  "bojackduy/nvim-herdr-navigation",
  commit = "7798a2f027465698cb1a51695327e138319f61f3",
  submodules = false,
  cond = function()
    return vim.env.HERDR_PANE_ID ~= nil
  end,
  event = "VeryLazy",
  init = function(plugin)
    vim.opt.rtp:prepend(plugin.dir .. "/nvim-herdr-navigation")
  end,
  config = function()
    vim.schedule(function()
      require("herdr-navigation").setup({
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
        },
      })
    end)
  end,
}
