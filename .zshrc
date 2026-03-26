# TODO: add .bashrc to .dotfiles
export ZSH="$HOME/.oh-my-zsh"
set -o ignoreeof
typeset -U path

setopt APPEND_HISTORY
setopt HIST_REDUCE_BLANKS
HISTSIZE=100000
SAVEHIST=100000
for i in {0..9}; do
  bindkey -r "^[$i"
done

setopt PROMPT_SUBST
ZSH_THEME=""
autoload -U promptinit; promptinit
# prompt pure # TODO: see https://github.com/sindresorhus/pure/issues/712
zstyle :prompt:pure:path color cyan
zstyle :prompt:pure:git:branch color "reset_color}on %f%F{magenta"
zstyle :prompt:pure:prompt:success color magenta 
source /usr/local/lib/node_modules/pure-prompt/async.zsh
source /usr/local/lib/node_modules/pure-prompt/pure.zsh
PROMPT='%{$fg[green]%}%n@%m%{$reset_color%} '$PROMPT
__pure_first_prompt=1
print() {
    if [[ $# -eq 0 && "${funcstack[-1]}" == "prompt_pure_precmd" && $__pure_first_prompt -eq 1 ]]; then
        __pure_first_prompt=0
        return
    fi
    builtin print "$@"
}
alias clear="__pure_first_prompt=1;command clear"

add_to_path() {
    if [[ $# -ne 1 ]]; then 
        echo "add_to_path expects 1 argument, $# provided"
        return 1;
    fi
    if [[ ":$PATH:" != *":$1:"* ]]; then
     export PATH="$1:$PATH"
    fi

}
add_to_path "$HOME/.local/bin"
add_to_path "/usr/local/bin"
export ZLS_PATH="/home/powna/install/zls/zls"

export EDITOR='nvim'

alias ga="git add"
alias gd="git diff"
alias gp="git push"
alias gpu="git pull"
alias gcl="git clone"
alias gs="git status"
alias gb="git branch"
alias gc="git commit"
alias gw="git worktree"

alias python="python3"
math() {
    python -c "from math import *; print(eval('$*'))"
}

TMUX_PROJECTS_FILE="$HOME/.tmux_projects"
alias tk="tmux kill-session"
alias tl="tmux list-sessions"
alias ta="tmux attach"
tn() {
    tmux new-session -s "$(echo $(basename $PWD) | sed 's/\.//g')"
}
ts() {
    local session_count=$(tmux list-sessions | wc -l) 
    if [[ $session_count -eq 1 ]]; then
        tmux attach
        return 0
    fi 
    
    local target=$(tmux list-sessions | 
        sed -E 's/:.*$//' |
        grep -v \"^"$(tmux display-message -p '#S')"\$\" |
        fzf --reverse --ghost="Session name" --height=15 \
        --border=rounded --border-label=" Open Tmux Session " \
        --preview 'tmux list-windows -t {} -F "#I:#W:#{?window_active,active,}" | 
            awk -F: "{
                if (\$3 == \"active\") 
                    printf \"\033[1;32m%s: %s (active)\033[0m\n\", \$1, \$2; 
                else 
                    printf \"\033[36m%s\033[0m: %s\n\", \$1, \$2}"')

    if [[ -z "$target" ]]; then
        return 0
    fi

    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$target"
    else
        tmux attach -t "$target"
    fi
}
tp() {
    if [[ ! -f "$TMUX_PROJECTS_FILE" ]]; then
        echo "No projects in $TMUX_PROJECTS_FILE. Use 'tpadd <dir>' first."
        return 1
    fi

    local lines=("${(@f)$(<"$TMUX_PROJECTS_FILE")}")
    local max_len=0
    for line in $lines; do
        local s_name=$(basename "$line" | sed 's/\.//g')
        if (( ${#s_name} > max_len )); then
            max_len=${#s_name}
        fi
    done

    local display=$( for line in $lines; do
        local s_name=$(basename "$line" | sed 's/\.//g')
        printf "%-${max_len}s  │  %s\n" "$s_name" "$line"
    done)

    local selection=$(fzf --reverse --height=15 --border=rounded \
        --border-label="Select Project" \
        --delimiter '  │  ' \
        --preview 'ls -CF --color=always {2}' <<<"$display")

    if [[ -z "$selection" ]]; then
        return 0
    fi
    local selected_path=$(echo "$selection" | awk -F '  │  ' '{print $2}' | xargs)

    local name=$(basename "$selected_path" | sed 's/\.//g')
    if ! tmux has-session -t "$name" 2>/dev/null; then
        tmux new-session -d -s "$name" -c "$selected_path"
    fi

    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$name"
    else
        tmux attach -t "$name"
    fi
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

eval "$(zoxide init zsh)"
alias cd="z"
alias cdi="zi"

export FZF_DEFAULT_OPTS=" \
--color=spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=border:#6C7086,label:#CDD6F4"

plugins=(git)

source $ZSH/oh-my-zsh.sh
. "/home/powna/.deno/env"
. "$HOME/.cargo/env"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
