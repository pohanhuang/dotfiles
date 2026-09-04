-- ~/.config/wezterm/config/startup.lua
local wezterm = require 'wezterm'
local mux = wezterm.mux

local autossh_bin = '/opt/homebrew/bin/autossh'

-- Clear stale focus/mouse modes so clicks are not forwarded into remote shells.
local reset_terminal_modes = table.concat({
  '\27[0m',
  '\27[?25h',
  '\27[?9l',
  '\27[?1000l',
  '\27[?1002l',
  '\27[?1003l',
  '\27[?1004l',
  '\27[?1005l',
  '\27[?1006l',
  '\27[?1015l',
  '\27[?2004l',
})

local function autossh(host)
  return {
    '/bin/sh',
    '-lc',
    ([[
      printf '%s'
      '%s' -M 0 -o ServerAliveInterval=30 -o ServerAliveCountMax=3 "$1"
      status=$?
      printf '%s'
      exit "$status"
    ]]):format(reset_terminal_modes, autossh_bin, reset_terminal_modes),
    'autossh-wrapper',
    host,
  }
end

wezterm.on('gui-startup', function(cmd)
  local tab1, pane1, window1 = mux.spawn_window {
    workspace = 'lab-43',
    args = autossh 'lab-43',
    set_environment_variables = {
      AUTOSSH_GATETIME = '0',
    },
  }
  tab1:set_title('lab-43')

  local tab2, pane2, window2 = mux.spawn_window {
    workspace = 'po-server',
    args = autossh 'po',
    set_environment_variables = {
      AUTOSSH_GATETIME = '0',
    },
  }
  tab2:set_title('po-server')

  local tab3, pane3, window3 = mux.spawn_window {
    workspace = 'local',
  }
  tab3:set_title('local')

  local tab4, pane4, window4 = mux.spawn_window {
    workspace = 'harvester-ui',
    cwd = '/Users/huangpohan/Desktop/suse/harvester-ui-extension',
  }
  tab4:set_title('harvester-ui')

  mux.set_active_workspace 'lab-43'
end)

return {
  exit_behavior = 'Hold',
}
