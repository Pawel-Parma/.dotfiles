export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

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

