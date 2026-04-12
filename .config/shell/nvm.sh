export NVM_DIR="$HOME/.nvm"
nvm node npm npx corepack () {
    unset -f nvm node npm npx corepack
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    "$0" "$@"
}

