-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Navigation
-- Navigation
vim.keymap.set("n", "<C-o>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("n", "<C-i>", "<C-o>", { desc = "Jump backward" })

-- Delete
vim.keymap.set({ "n", "v" }, "<leader>dd", '"_dd', { desc = "Delete line (no yank)" })
vim.keymap.set({ "n", "v" }, "<leader>dr", '"_d', { desc = "Delete (no yank)" })

-- Diffview
vim.keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open" })
vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close" })
vim.keymap.set("n", "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History" })
