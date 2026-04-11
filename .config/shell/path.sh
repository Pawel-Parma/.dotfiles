path_add() {
    if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

export ZLS_PATH="$HOME/install/zls/zls"
export FZF_PATH="$HOME/install/fzf/bin"
export EDITOR='nvim'
export PAGER='less -FR'
export GPG_TTY=$(tty)
path_add "$HOME/.local/bin"
path_add "/usr/local/bin"
path_add "$FZF_PATH"
path_add "$HOME/.deno/bin"
path_add "$HOME/.cargo/bin"

