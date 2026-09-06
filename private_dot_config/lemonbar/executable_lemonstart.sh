#!/usr/bin/env bash

killall -q lemonbar

while pgrep -u $UID -x lemonbar >/dev/null; do sleep 1; done

FONT='-*-Hack Nerd Font Mono-medium-r-normal--*-110-*-*-*-*-iso10640-1'

~/.config/lemonbar/lemonconfig.py | \
	lemonbar -p -g 2440x24 -f "${FONT}" -B '#bf18191a' -u 2 | \
	$(/usr/bin/env bash)
