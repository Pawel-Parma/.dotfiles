local shell=$(ps -p $$ -o comm= | sed 's/^-//')

eval "$(zoxide init "$shell")"
alias cd="z"
alias cdi="zi"

