local wezterm = require 'wezterm'

local Config = {}
Config.__index = Config

function Config:init()
  local instance = setmetatable({}, Config)
  instance.options = wezterm.config_builder()
  return instance
end

function Config:append(module)
  for key, value in pairs(module) do
    self.options[key] = value
  end
  return self
end

return Config
