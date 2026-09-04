local wezterm = require("wezterm")
local act = wezterm.action

return {
	keys = {
		-- ─── Split panes ────────────────────────────────────────────────────────
		{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

		-- ─── Navigate panes (CMD+SHIFT+Arrow, avoids text nav conflict) ─────────
		{ key = "LeftArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Left") },
		{ key = "RightArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Right") },
		{ key = "UpArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Up") },
		{ key = "DownArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Down") },

		-- ─── Switch tabs (CMD+[/]) ───────────────────────────────────────────────
		{ key = "j", mods = "CMD", action = act.ActivateTabRelative(-1) },
		{ key = "l", mods = "CMD", action = act.ActivateTabRelative(1) },

		-- ─── Tab utilities ───────────────────────────────────────────────────────
		{ key = "p", mods = "CMD", action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
		{
			key = "n",
			mods = "CMD",
			action = act.PromptInputLine({
				description = "Tab name:",
				action = wezterm.action_callback(function(window, _, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},

		-- ─── Close pane ─────────────────────────────────────────────────────────
		{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

		-- ─── Text navigation ────────────────────────────────────────────────────
		-- OPT+Arrow: word jump
		{ key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
		{ key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
		-- CMD+Arrow: line start/end (no conflict now)
		{ key = "LeftArrow", mods = "CMD", action = act.SendString("\x01") }, -- Ctrl+A
		{ key = "RightArrow", mods = "CMD", action = act.SendString("\x05") }, -- Ctrl+E
	},
}
