local shell=$(ps -p $$ -o comm= | sed 's/^-//')

export FZF_DEFAULT_OPTS=" \
--color=spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=border:#6C7086,label:#CDD6F4"
source "$FZF_PATH/../shell/key-bindings.$shell"
source "$FZF_PATH/../shell/completion.$shell"
