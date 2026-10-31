export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

# TODO:
# Exit in non interactive mode

set -o ignoreeof

setopt APPEND_HISTORY
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY     
setopt SHARE_HISTORY
unsetopt HIST_IGNORE_SPACE
HISTSIZE=100000
SAVEHIST=100000

bindkey -e
bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history
for i in {0..9}; do
  bindkey -r "^[$i"
done

if [[ -f "$HOME/.config/shell/common.sh" ]]; then
    source "$HOME/.config/shell/common.sh"
fi

# TODO:
# CASE_SENSITIVE="false"
# HYPHEN_INSENSITIVE="false"
# plugins=(git)
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# source $ZSH/oh-my-zsh.sh
# ZSH_HIGHLIGHT_STYLES[command]='fg=yellow,bold'

