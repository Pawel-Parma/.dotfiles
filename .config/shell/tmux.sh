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

tget_name() {
    basename $1 | sed 's/\.//g'
}

tselect() {
    if [[ -n "$2" ]]; then
        printf "%s\n" "$1" | fzf --delimiter '  │  ' --filter="$1"  | head -n 1
        return
    fi

    printf "%s\n" "$1" |
    if [[ -n "$TMUX" ]]; then
        grep -v "^$(tmux display -p '#S')"
    else
        cat
    fi |
    fzf --reverse --height=15 --ghost="Session name" \
        --border-label=" Open Tmux Session " --border=rounded \
        --delimiter '  │  ' --preview "$TMUX_PREVIEW_CMD"
}

tls() {
    tmux list-sessions -F "#{?session_attached,attached,detached}|#{session_name}" |
    while IFS="|" read -r s_status name; do
        if [[ "$s_status" == "attached" ]]; then
            printf "\e[32m● attached \e[0m"
        else
            printf "\e[90m○ detached \e[0m"
        fi
        printf "\e[1;36m%-15s\e[0m\n" "$name"
    done
}

tlp() {
    touch "$TMUX_PROJECTS_FILE"
    local yellow=$'\e[37m'
    local blue=$'\e[34;1m'
    local reset=$'\e[0m'
    while read -r full_path; do
        local parent="$(dirname "$full_path")/"
        local base="$(basename "$full_path")"
        local color_base=$(echo "$base" | sed "s/\./${yellow}.${blue}/g")
        printf "${yellow}%s${blue}%s${reset}\n" "$parent" "$color_base"
    done < "$TMUX_PROJECTS_FILE"
}

tks() {
    tmux kill-server
}

tk() {
    local projects="$(tmux ls -f "#s")"
    local selection="$(tselect "$projects" "$1")"
    if [[ -z "$selection" ]]; then
        return 0
    fi

    tmux kill-session "$selection"
}

ta() {
    if [[ -n "$TMUX" ]]; then
        tmux switchc ${1:+ -t "$1"}
    else
        tmux attach ${1:+ -t "$1"}
    fi
    return $?
}

tn() {
    local dpath="${1:-$PWD}"
    tmux new -s "$(tget_name "$dpath")" -c "$dpath"
    return $?
}

ts() {
    if ! tmux has 2> /dev/null; then
        tp "$1"
        return $?
    fi
    if [[ $(tmux ls | wc -l) -eq 1 ]]; then
        ta
        return $?
    fi

    local projects="$(tmux ls -f "#s")"
    local selection="$(tselect "$projects" "$1")"
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

    local projects="$(awk "$TMUX_PROCESS_PROJECTS" "$TMUX_PROJECTS_FILE")"
    local selection="$(tselect "$projects" "$1")"
    if [[ -z "$selection" ]]; then
        return 0
    fi

    local dpath=$(echo "$selection" | awk -F '  │  ' '{print $2}' | xargs)
    local name=$(tget_name "$dpath")
    if ! tmux has -t "$name" 2>/dev/null; then
        tmux new -d -s "$name" -c "$dpath"
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

tpremove() {
    if [[ ! -f "$TMUX_PROJECTS_FILE" ]]; then
        echo "No projects in $TMUX_PROJECTS_FILE. Use 'tpadd <dir>' first."
        return 1
    fi

    local projects="$(awk "$TMUX_PROCESS_PROJECTS" "$TMUX_PROJECTS_FILE")"
    local selection="$(tselect "$projects" "$1")"
    if [[ -z "$selection" ]]; then
        return 0
    fi

    local dpath=$(echo "$selection" | awk -F '  │  ' '{print $2}' | xargs)
    grep -vxF "$dpath" "$TMUX_PROJECTS_FILE" > "${TMUX_PROJECTS_FILE}.remove.tmp"
    mv "$TMUX_PROJECTS_FILE" "${TMUX_PROJECTS_FILE}.remove.old"
    mv "${TMUX_PROJECTS_FILE}.remove.tmp" "$TMUX_PROJECTS_FILE"
}

tpclean() {
    touch "$TMUX_PROJECTS_FILE"
    touch "${TMUX_PROJECTS_FILE}.clean.tmp"
    while read -r dpath; do
        if [[ -d "$dpath" ]]; then
            echo "$dpath" >> "${TMUX_PROJECTS_FILE}.clean.tmp";
        else
            echo "Removed: $dpath"
        fi
    done < "$TMUX_PROJECTS_FILE"
    mv "$TMUX_PROJECTS_FILE" "${TMUX_PROJECTS_FILE}.clean.old"
    mv "${TMUX_PROJECTS_FILE}.clean.tmp" "$TMUX_PROJECTS_FILE"
}
