-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- OSC 52 clipboard: write-only (no query) to avoid SSH latency
vim.g.clipboard = {
  name = "macOS OSC52 via tmux outer tty",

  copy = {
    ["+"] = { "/home/po/.config/tmux/scripts/yank-osc52.sh" },
    ["*"] = { "/home/po/.config/tmux/scripts/yank-osc52.sh" },
  },

  paste = {
    ["+"] = false,
    ["*"] = false,
  },

  cache_enabled = 0,
}

vim.opt.clipboard = "unnamedplus"
vim.g.lazyvim_check_order = false
