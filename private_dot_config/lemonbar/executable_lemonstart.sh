#!/usr/bin/env bash

killall -q lemonbar

while pgrep -u $UID -x lemonbar >/dev/null; do sleep 1; done

~/.config/lemonbar/lemonconfig.py | \
	lemonbar -p -g 1825x20 -f 'Hack Nerd Font'-11 -B '#bf18191a' -u 2 | \
	$(/usr/bin/env bash)
