return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections = opts.sections or {}
    opts.sections.lualine_a = {
      {
        function()
          local t = vim.b.snacks_terminal
          if t and t.cmd == "pi" then return "PI" end
          return require("lualine.utils.mode").get_mode()
        end,
      },
    }
    opts.sections.lualine_c = {
      {
        "filename",
        path = 1,
        shorting_target = 0,
      },
    }
    return opts
  end,
}
