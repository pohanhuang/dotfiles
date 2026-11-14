return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.styles = opts.styles or {}
      opts.styles.terminal = { position = "right" }
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = {
        hidden = true,
        ignored = true,
        exclude = { ".git" },
        format = function(item, picker)
          local name = item.file and vim.fn.fnamemodify(item.file, ":t") or ""
          if name ~= ".gitignore" then
            local restored = {}
            local it = item
            while it do
              if it.hidden then
                restored[it] = true
                it.hidden = false
              end
              it = it.parent
            end
            local result = require("snacks.picker.format").file(item, picker)
            for node in pairs(restored) do
              node.hidden = true
            end
            return result
          end
          return require("snacks.picker.format").file(item, picker)
        end,
        win = {
          list = {
            keys = {
              ["<c-t>"] = false,
            },
          },
        },
      }
      opts.picker.sources.files = {
        hidden = true,
        ignored = false,
      }
      return opts
    end,
  },
}
