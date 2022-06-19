local wezterm = require 'wezterm';

return {
	color_scheme = "Gruvbox Dark",
	font = wezterm.font("Iosevka Term"),
	leader = {key="a", mods="CTRL", timeout_milliseconds=400},
	keys = {
		{key="c", mods="LEADER", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
		{key="n", mods="LEADER", action=wezterm.action{ActivateTabRelative=1}},
		{key="p", mods="LEADER", action=wezterm.action{ActivateTabRelative=-1}},
		{key="&", mods="LEADER|SHIFT", action=wezterm.action{CloseCurrentTab={confirm=true}}},
		{key="a", mods="LEADER|CTRL", action=wezterm.action{SendString="\x01"}},
	},
	scrollback_lines = 100000,
}
