return {
  "anuvyklack/hydra.nvim",
  event = "VeryLazy",
  config = function()
    -- register group so which-key shows it under <leader>h
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ { "<leader>h", group = "hydra" } })
      wk.add({ { "<leader>hd", desc = "Diffview" } })
    end

    local Hydra = require("hydra")

    Hydra({
      name = "Diffview",
      hint = [[
 Diffview
 _o_: open   _c_: close   _h_: file history

 Conflict
 _co_: ours   _ct_: theirs   _cT_: both
 _n_: next    _p_: prev

 _<Esc>_/_q_: quit
      ]],
      config = {
        color = "teal",
        invoke_on_body = true,
        hint = {
          position = "bottom",
          border = "rounded",
        },
      },
      mode = "n",
      body = "<leader>hd",
      heads = {
        -- diffview
        { "o", "<cmd>DiffviewOpen<cr>" },
        { "c", "<cmd>DiffviewClose<cr>" },
        { "h", "<cmd>DiffviewFileHistory %<cr>" },
        -- git-conflict
        { "co", "<cmd>GitConflictChooseOurs<cr>" },
        { "ct", "<cmd>GitConflictChooseTheirs<cr>" },
        { "cT", "<cmd>GitConflictChooseBoth<cr>" },
        { "n", "<cmd>GitConflictNextConflict<cr>" },
        { "p", "<cmd>GitConflictPrevConflict<cr>" },
        -- exit
        { "q", nil, { exit = true } },
        { "<Esc>", nil, { exit = true } },
      },
    })
  end,
}
