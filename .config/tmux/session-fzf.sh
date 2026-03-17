#!/usr/bin/bash
tmux list-sessions |
sed -E 's/:.*$//' |
grep -v \"^"$(tmux display-message -p '#S')"\$\" |
fzf --reverse --ghost="Session name" --border=rounded --border-label=" Switch Tmux Session " |
xargs tmux switch-client -t
