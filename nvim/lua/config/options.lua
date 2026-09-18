-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- OSC 52 clipboard, built into nvim: works under tmux, herdr and plain ssh.
-- (the old yank-osc52.sh wrote to /dev/tty, which clipboard jobs don't have)
vim.g.clipboard = "osc52"
vim.opt.clipboard = "unnamedplus"
vim.g.lazyvim_check_order = false

-- Enable auto reload for better reflect the agnet changes
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})
