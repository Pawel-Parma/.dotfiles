local shell=$(ps -p $$ -o comm= | sed 's/^-//')
eval "$(starship init "$shell")"

if [[ "$SHELL_PID" -eq "$$" ]]; then
    __first_prompt=0
else
    __first_prompt=1
fi
export SHELL_PID="$$"

_starship_newline() {
    if [[ __first_prompt -eq 1 ]]; then
        __first_prompt=0
        return
    fi
    echo ""
}

alias clear="__first_prompt=1;command clear"


case "$shell" in
    zsh)
        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_newline
        ;;
    bash)
        if [[ "$PROMPT_COMMAND" != *"_starship_newline"* ]]; then
            PROMPT_COMMAND="_starship_newline; $PROMPT_COMMAND"
        fi
        ;;
    *)
        echo "_starship_newline was not added to $shell"
        ;;
esac

