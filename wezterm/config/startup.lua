-- ~/.config/wezterm/config/startup.lua
local wezterm = require 'wezterm'
local mux = wezterm.mux

local autossh_bin = '/opt/homebrew/bin/autossh'

local function autossh(host)
  return {
    autossh_bin,
    '-M',
    '0',
    '-o',
    'ServerAliveInterval=30',
    '-o',
    'ServerAliveCountMax=3',
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
