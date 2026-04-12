#!/usr/bin/bash
TMUX_PROJECTS_FILE="$HOME/.tmux/projects"
TMUX_PREVIEW_CMD='
if tmux has-session -t {1} 2>/dev/null; then
    tmux list-windows -t {1} -F "#I:#W:#{?window_active,active,}" |
    awk -F: "{
        if (\$3 == \"active\")
            printf \"\033[1;32m%s: %s (active)\033[0m\n\", \$1, \$2;
        else
            printf \"\033[36m%s\033[0m: %s\n\", \$1, \$2
    }"
else
    echo "\033[1;36m[Project not started]\033[0m"
    ls -CF --color=always {2}
fi
'
TMUX_PROCESS_PROJECTS='{
    lines[NR] = $0
    s_name = $0
    sub(/.*\//, "", s_name)
    gsub(/\./, "", s_name)
    names[NR] = s_name
    if (length(s_name) > max_len) {
        max_len = length(s_name)
    }
} END {
    for (i = 1; i <= NR; i++) {
        printf "%-*s  │  %s\n", max_len, names[i], lines[i]
    }
}'

if [[ ! -f "$TMUX_PROJECTS_FILE" ]]; then
    echo "No projects in $TMUX_PROJECTS_FILE. Use 'tpadd <dir>' first."
    exit 1
fi

projects=$(awk "$TMUX_PROCESS_PROJECTS" "$TMUX_PROJECTS_FILE")
selection=$(echo "$projects" | grep -v "^$(tmux display -p '#S')" |
    fzf --reverse --height=15 --ghost="Session name" \
        --border-label=" Open Tmux Session " --border=rounded \
    --delimiter '  │  ' --preview "$TMUX_PREVIEW_CMD")
if [[ -z "$selection" ]]; then
    exit
fi

selected_path=$(echo "$selection" | awk -F '  │  ' '{print $2}' | xargs)
name=$(basename "$selected_path" | sed 's/\.//g')
if ! tmux has -t "$name" 2>/dev/null; then
    tmux new -d -s "$name" -c "$selected_path"
fi

tmux switchc -t "$name"


