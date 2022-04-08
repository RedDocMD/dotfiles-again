#!/usr/bin/env python3

import subprocess
import time
import sys
from datetime import datetime

def pprint(*args):
    print(*args, end='', sep='')

def get_workspaces():
    return {
        1: 'I',
        2: 'II',
        3: 'III',
        4: 'IV',
        5: 'V',
        6: 'VI',
        7: 'VII',
        8: 'VIII',
        9: 'IX',
        10: 'X',
    }

def extract_workspace_nums(proc):
    num_strs = proc.stdout.decode('utf-8').split('\n')
    return set(map(int, filter(lambda x: len(x) != 0 and x != 'Desktop', num_strs)))

def do_workspaces():
    proc = subprocess.run(['bspc', 'query', '--names', '-D', '-d', '.occupied'], capture_output=True)
    occupied_workspaces = extract_workspace_nums(proc)
    proc = subprocess.run(['bspc', 'query', '--names', '-D', '-d', '.focused'], capture_output=True)
    focused_workspaces = extract_workspace_nums(proc)
    proc = subprocess.run(['bspc', 'query', '--names', '-D', '-d', '.urgent'], capture_output=True)
    urgent_workspaces = extract_workspace_nums(proc)

    workspaces = get_workspaces()
    workspace_nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    for wk_num in workspace_nums:
        if wk_num in urgent_workspaces:
            pprint('%{U#9b0a20}%{+u}', workspaces[wk_num], '%{U-}%{-u}', ' ')
        elif wk_num in focused_workspaces:
            pprint('%{U#fba922}%{+u}', workspaces[wk_num], '%{U-}%{-u}', ' ')
        elif wk_num in occupied_workspaces:
            pprint('%{F#ffaa00}', workspaces[wk_num], '%{F-}', ' ')
        else:
            pprint('%{F#555555}', workspaces[wk_num], '%{F-}', ' ')


def do_window_title():
    proc = subprocess.run(['bspc', 'query', '-N', '-n', '.focused'], capture_output=True)
    window_id = proc.stdout.decode('utf-8').strip('\n')
    proc = subprocess.run(['xtitle', window_id], capture_output=True)
    window_title = proc.stdout.decode('utf-8').strip('\n')
    pprint(window_title)


def do_time():
    now = datetime.now()
    now_str = now.strftime('%a %d %b, %I:%M %p')
    pprint('%{F#c2c0c0}', now_str, '%{F-}')


def bar():
    # Left aligned stuff
    pprint('%{O10}')
    do_time()
    pprint('%{O20}')
    do_workspaces()

    # Center aligned stuff
    pprint('%{c}')
    do_window_title()

    # Right aligned stuff
    pprint('%{r}')
    pprint('%{O10}')

    # Print newline
    print()


if __name__ == "__main__":
    while True:
        bar()
        sys.stdout.flush()
        time.sleep(1/10)
