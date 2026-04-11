TMUX_PROJECTS_FILE="$HOME/.tmux_projects"
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

alias tk="tmux kill-session"
alias tks="tmux kill-server"
alias tl="tmux ls"
alias tpa="tpadd"

tget_name() {
    basename $1 | sed 's/\.//g'
}

tselect() {
    printf "%s\n" "$@" |
    if [[ -n "$TMUX" ]]; then
        local current_session="$(tmux display -p '#S')"
        grep -v "^${current_session}"
    else
        cat
    fi |
    fzf --reverse --height=15 --ghost="Session name" \
        --border-label=" Open Tmux Session " --border=rounded \
        --delimiter '  │  ' --preview "$TMUX_PREVIEW_CMD"
}

ta() {
    if [[ -n "$TMUX" ]]; then
        tmux switchc -t "$1"
    else
        tmux attach -t "$1"
    fi
    return $?
}

tn() {
    tmux new -s "$(tget_name "$PWD")"
    return $?
}

ts() {
    if ! tmux has 2> /dev/null; then
        tp
        return $?
    fi
    if [[ $(tmux ls | wc -l) -eq 1 ]]; then
        ta
        return $?
    fi

    local selection=$(tselect $(tmux ls -F "#S"))
    if [[ -z "$selection" ]]; then
        return 0
    fi

    ta "$selection"
    return $?
}

tp() {
    if [[ ! -f "$TMUX_PROJECTS_FILE" ]]; then
        echo "No projects in $TMUX_PROJECTS_FILE. Use 'tpadd <dir>' first."
        return 1
    fi

    local projects=$(awk "$TMUX_PROCESS_PROJECTS" "$TMUX_PROJECTS_FILE")
    local selection=$(tselect "$projects")
    if [[ -z "$selection" ]]; then
        return 0
    fi

    local selected_path=$(echo "$selection" | awk -F '  │  ' '{print $2}' | xargs)
    local name=$(tget_name "$selected_path")

    if ! tmux has -t "$name" 2>/dev/null; then
        tmux new -d -s "$name" -c "$selected_path"
    fi

    ta "$name"
    return $?
}

tpadd() {
    if [[ $# -gt 1 ]]; then
        echo "tpadd expects 0 or 1 arguments, $# provided"
        return 1;
    fi
    local target=$(realpath "${1:-$PWD}")
    if [[ ! -d "$target" ]]; then
        echo "Error: $target is not a valid directory."
        return 1
    fi

    touch "$TMUX_PROJECTS_FILE"

    if grep -Fxq "$target" "$TMUX_PROJECTS_FILE"; then
        echo "Project already in list."
    else
        echo "$target" >> "$TMUX_PROJECTS_FILE"
        echo "Added $target"
    fi
}

