export ZSH="$HOME/.oh-my-zsh"
# TODO: refactor

set -o ignoreeof
export FZF_DEFAULT_OPTS=" \
--color=spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=border:#6C7086,label:#CDD6F4"

setopt PROMPT_SUBST
git_branch() {
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
  if [[ -z $branch ]]; then
    branch=$(git rev-parse --short HEAD 2>/dev/null)
  fi
  if [[ -n $branch ]]; then
      echo "on %{$fg[magenta]%}$branch%{$reset_color%}"
  fi
}

PROMPT='%{$fg[green]%}%n@%m%{$reset_color%} \
%{$fg[cyan]%}%~%{$reset_color%} $(git_branch)
%{$fg[magenta]%}❯%{$reset_color%} '

. "$HOME/.cargo/env"
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$HOME/install/zig/zig-x86_64-linux-0.16.0-dev.368+2a97e0af6:$PATH"
export PATH="$HOME/install/zls:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export ZLS_PATH="/home/powna/install/zls/zls"
HISTSIZE=100000
HISTFILESIZE=200000
alias ga="git add"
alias gd="git diff"
alias gc="git commit"
alias gcl="git clone"
alias gs="git status"
alias gp="git push"
alias gpu="git pull"
alias gw="git worktree"

alias python="python3"

alias perf='/usr/lib/linux-tools-6.8.0-90/perf'
export PERF_='/usr/lib/linux-tools-6.8.0-90/perf'

tn() {
    tmux new-session -s "$(echo $(basename $PWD) | sed 's/\.//g')"
}

ta() {
    if [[ -n $1 ]]; then
        tmux attach -t "$1"
        return
    fi

    local name="$(basename "$PWD" | sed 's/\.//g')"
    if tmux has-session -t "$name" 2>/dev/null; then
        tmux attach -t "$name"
    else
        tmux attach
    fi
}

ts() {
    local target=$(tmux list-sessions |
    sed -E 's/:.*$//' |
    grep -v \"^"$(tmux display-message -p '#S')"\$\" |
    fzf --reverse --ghost="Session name" --height=15 --border=rounded --border-label=" Open Tmux Session ")

    if [[ -z "$target" ]]; then
        return 0
    fi

    tmux attach -t "$target"
}


alias tl="tmux list-sessions"
eval "$(zoxide init zsh)"
alias cd="z"
alias cdi="zi"

math() {
    python3 -c "from math import *; print(eval('$*'))"
}


# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
. "/home/powna/.deno/env"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
