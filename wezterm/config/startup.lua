-- ~/.config/wezterm/config/startup.lua
local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local tab1, pane1, window1 = mux.spawn_window {
    workspace = 'lab-43',
    args = { 'ssh', 'lab-43' },
  }
  tab1:set_title('lab-43')

  local tab2, pane2, window2 = mux.spawn_window {
    workspace = 'po-server',
    args = { 'ssh', 'po' },
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

return {}
