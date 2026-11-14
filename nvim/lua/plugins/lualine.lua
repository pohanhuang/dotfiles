return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections = opts.sections or {}
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
