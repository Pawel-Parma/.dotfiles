#!/usr/bin/bash
set -uo pipefail

check() {
    if ! command -v apt >/dev/null 2>&1; then
        echo "Error: apt not found. Other package managers are not supported.\n Exiting..."
        exit 1
    fi
}

update() {
    echo "Updating apt..."
    sudo apt update >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update apt" >&2
        exit 2
    fi
}

finish() {
    echo "Packages installed succesfully"
}

_execute_install() {
    local cmd="$1"
    local package="$2"
    local version_query="$3"

    echo -n "Installing $package"
    sudo $cmd "$package" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: failed to install $package" >&2
        exit 5
    fi

    local ver
    ver=$(eval "$version_query" 2>/dev/null)
    echo " ($ver)"
}

apt_install() {
    if [ $# -ne 1 ]; then
        echo "Error: $# arguments passed, install requires 1 arguments" >&2
        exit 3
    fi
    _execute_install "apt install -y" "$1" "dpkg-query -W -f='\${Version}' $1"
}

npm_install() {
    if [ $# -ne 1 ]; then
        echo "Error: $# arguments passed, npm_install requires 1 argument" >&2
        exit 3
    fi
    _execute_install "npm install -g" "$1" "npm list -g --depth=0 '$1' | grep -oP '$1@\K[\d.]+'"
}

curl_install() {
    if [ $# -ne 1 ]; then
        echo "Error: $# arguments passed, clone requires 1 arguments" >&2
        exit 3
    fi
    local link="$1"
    # TODO: find a way to automate interactive scripts
    curl -sSfL "$link" | sh
}

install() {
    apt_install stow

    apt_install zsh
    # apt_install fzf TODO: this version is too old
    apt_install cloc
    apt_install tree
    apt_install fastfetch
    # curl_install https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh # zoxide

    apt_install nodejs
    apt_install npm
    npm_install tree-sitter-cli
    npm_install typescript
    npm_install deno
    npm_install pure-prompt

    apt_install unzip
    apt_install ripgrep
    apt_install fd-find
    apt_install texlive-full
    apt_install neovim
    apt_install tmux

    apt_install golang-go
}

main() {
    update
    check
    install
    finish
}

main

