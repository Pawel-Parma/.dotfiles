#!/usr/bin/bash
TMUX_PREVIEW_CMD='
tmux list-windows -t {1} -F "#I:#W:#{?window_active,active,}" |
awk -F: "{
    if (\$3 == \"active\")
        printf \"\033[1;32m%s: %s (active)\033[0m\n\", \$1, \$2;
    else
        printf \"\033[36m%s\033[0m: %s\n\", \$1, \$2
}"
'

tmux ls -F "#S" |
grep -vx "$(tmux display -p '#S')" |
fzf --reverse --height=15 --ghost="Session name" --border-label=" Switch Tmux Session " --border=rounded --preview "$TMUX_PREVIEW_CMD" |
xargs tmux switchc -t

