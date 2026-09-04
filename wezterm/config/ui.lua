local wezterm = require("wezterm")

return {
	hide_tab_bar_if_only_one_tab = true,
	color_scheme = "Dracula+",
	font = wezterm.font_with_fallback({
		{ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
		{ family = "Sarasa Mono SC", weight = "Regular" },
		"PingFang SC",
	}),
	font_size = 14.0,
}
