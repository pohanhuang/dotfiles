-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Navigation
-- Navigation
vim.keymap.set("n", "<C-o>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("n", "<C-i>", "<C-o>", { desc = "Jump backward" })

-- Default delete/change -> blackhole
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete to black hole" })
vim.keymap.set({ "n", "v" }, "c", '"_c', { desc = "Change to black hole" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete char to black hole" })

-- Explicit normal Vim delete
vim.keymap.set({ "n", "v" }, "<leader>D", "d", { desc = "Normal delete" })
