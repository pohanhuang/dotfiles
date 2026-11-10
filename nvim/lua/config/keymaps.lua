-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Navigation
vim.keymap.set("n", "<C-o>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("n", "<C-i>", "<C-o>", { desc = "Jump backward" })

-- Default delete/change -> blackhole
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete to black hole" })
vim.keymap.set({ "n", "v" }, "c", '"_c', { desc = "Change to black hole" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete char to black hole" })

-- Explicit normal Vim delete
vim.keymap.set({ "n", "v" }, "<leader>D", "d", { desc = "Normal delete" })

-- Buffer controls
vim.keymap.set("n", "<C-e>", "<cmd>bdelete<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<C-q>", "<cmd>%bdelete<cr>", { desc = "Close all buffers" })


--Vetical buffe Split
vim.keymap.set("n", "<leader>bL", "<cmd>rightbelow vsplit | wincmd p | bnext | wincmd p<cr>",
  { desc = "Split buffer right" })
vim.keymap.set("n", "<leader>bH", "<cmd>leftabove vsplit | wincmd p | bnext | wincmd p<cr>",
  { desc = "Split buffer left" })

-- Terminal (right vertical split)
vim.keymap.set({ "n", "t" }, "<c-t>", function()
  Snacks.terminal.focus(nil, { count = 99 })
end, { desc = "Terminal (Root Dir)" })

-- Open file from selection/clipboard (path:line format)
vim.keymap.set("n", "<leader>of", function()
  local clip = vim.fn.getreg("*")
  clip = clip:match("^%s*(.-)%s*$") -- trim whitespace
  local path, line = clip:match("^(.+):(%d+)$")
  if not path then path = clip end
  if path == "" then return end
  vim.schedule(function()
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    if line then vim.cmd(line) end
  end)
end, { desc = "Open file from selection" })

--Window size move
vim.keymap.set("n", "<leader>w.", "<cmd>vertical resize +10<cr>", { desc = "Wider" })
vim.keymap.set("n", "<leader>w,", "<cmd>vertical resize -10<cr>", { desc = "Narrower" })
