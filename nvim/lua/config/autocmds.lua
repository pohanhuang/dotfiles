-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- (clipboard is set in options.lua via vim.g.clipboard = "osc52")

-- In terminal buffers, Ctrl+click a file path (optionally `:line[:column]`)
-- emitted by Pi to open it in the previous editor window.
local function open_terminal_file(path, line, column, terminal_win)
  local file = vim.fn.expand(path)
  if not file:match("^/") then
    -- Resolve against the terminal process's cwd (where pi runs), not nvim's.
    local pid = vim.b[vim.api.nvim_win_get_buf(terminal_win)].terminal_job_pid
    local term_cwd = pid and vim.uv.fs_realpath("/proc/" .. pid .. "/cwd")
    local candidate = term_cwd and term_cwd .. "/" .. file
    file = (candidate and vim.fn.filereadable(candidate) == 1) and candidate or vim.fn.getcwd() .. "/" .. file
  end
  if vim.fn.filereadable(file) == 0 then
    vim.notify("File not found: " .. file, vim.log.levels.WARN)
    return
  end

  vim.schedule(function()
    vim.cmd("stopinsert")
    local previous = vim.fn.win_getid(vim.fn.winnr("#"))
    if previous ~= 0 and previous ~= terminal_win and vim.api.nvim_win_is_valid(previous) then
      vim.api.nvim_set_current_win(previous)
    else
      vim.cmd("leftabove vsplit")
    end
    vim.cmd("edit +" .. (line or 1) .. " " .. vim.fn.fnameescape(file))
    if column then
      vim.api.nvim_win_set_cursor(0, { line, math.max(0, column - 1) })
    end
  end)
end

local function open_terminal_reference()
  local mouse = vim.fn.getmousepos()
  if mouse.winid == 0 or mouse.line <= 0 then return end

  local buf = vim.api.nvim_win_get_buf(mouse.winid)
  local text = vim.api.nvim_buf_get_lines(buf, mouse.line - 1, mouse.line, false)[1] or ""
  local start = 1
  while true do
    local first, last, path, line, column = text:find("([%w%._~/%-]+):(%d+):?(%d*)", start)
    if not first then break end
    if mouse.column >= first and mouse.column <= last then
      open_terminal_file(path, tonumber(line), column ~= "" and tonumber(column) or nil, mouse.winid)
      return
    end
    start = last + 1
  end

  -- Also support bare paths, such as the output of `find`.
  start = 1
  while true do
    local first, last, path = text:find("([%w%._~/%-]+)", start)
    if not first then break end
    if mouse.column >= first and mouse.column <= last and path:match("%.[%w_%-]+$") then
      open_terminal_file(path, nil, nil, mouse.winid)
      return
    end
    start = last + 1
  end
end

local terminal_links = vim.api.nvim_create_augroup("terminal_links", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_links,
  callback = function(event)
    vim.bo[event.buf].scrollback = 100000
    vim.keymap.set("t", "<C-LeftMouse>", open_terminal_reference, {
      buffer = event.buf,
      desc = "Open terminal file reference",
    })
  end,
})
