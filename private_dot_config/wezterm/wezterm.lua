local wezterm = require 'wezterm';
local table = require 'table';

local tmux_keys = {
	{key="c", mods="LEADER", action=wezterm.action{SpawnCommandInNewTab={cwd=wezterm.home_dir}}},
	{key="n", mods="LEADER", action=wezterm.action{ActivateTabRelative=1}},
	{key="p", mods="LEADER", action=wezterm.action{ActivateTabRelative=-1}},
	{key="&", mods="LEADER|SHIFT", action=wezterm.action{CloseCurrentTab={confirm=true}}},
	{key="a", mods="LEADER|CTRL", action=wezterm.action{SendString="\x01"}},
	{key="-", mods="LEADER", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain", cwd=wezterm.home_dir}}},
	{key="\\", mods="LEADER", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain", cwd=wezterm.home_dir}}},
	{key="j", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Down"}},
	{key="k", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Up"}},
	{key="l", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Right"}},
	{key="h", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Left"}},
}

local misc_keys = {
  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local overrides = window:get_config_overrides() or {}
      if not overrides.harfbuzz_features then
        overrides.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
      else
        overrides.harfbuzz_features = nil
      end
      window:set_config_overrides(overrides)
    end),
  },
}

local keys = {}
for _, key in ipairs(tmux_keys) do
	table.insert(keys, key)
end
for _, key in ipairs(misc_keys) do
	table.insert(keys, key)
end
for i = 1, 9 do
	table.insert(keys,
	  {key=tostring(i), mods="LEADER", action=wezterm.action{ActivateTab=i-1}})
end

return {
	color_scheme = "Gruvbox dark, hard (base16)",
	font = wezterm.font("Iosevka Term Curly", { weight = "Medium", stretch = "Expanded" }),
	font_size = 13.5,
	leader = {key="a", mods="CTRL", timeout_milliseconds=400},
	keys = keys,
	scrollback_lines = 100000,
	ssh_domains = {
		{name="collosus", remote_address="192.168.29.47", username="dknite"}
	},
	hyperlink_rules = {
		{
			regex = [[\b\w+://[\w.-]+\.[a-z]{2,15}\S*\b]],
			format = "$0",
		},
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = "$0",
		},
		{
			regex = [[\bhttp://localhost:\d{1,4}\b]],
			format = "$0",
		}
	},
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
}
