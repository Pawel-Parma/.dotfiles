import() {
    if [[ "$#" -ne 1 ]]; then
        echo "Error: not enough arguments provided: $?"
        return 1
    fi

    local src="$HOME/.config/shell/$1"
    if [ -f "$src" ]; then
        . "$src"
    else
        echo "Error: could not source: $src"
        return 2
    fi
}

import prompt.sh
import path.sh
import git.sh
import python.sh
import tmux.sh
import zoxide.sh
import fzf.sh
import nvm.sh

