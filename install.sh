#!/usr/bin/env bash
set -uo pipefail

clone() {
    local repo="$1"
    local target="$2"

    if [ -z "$target" ] || [ -z "$repo" ]; then
        echo "Error: not enough arguments passed, clone requires 2 arguments" >&2
        exit 1
    fi

    if [ "${3-}" ]; then
        echo "Error: too many arguments passed, clone requires 2 arguments" >&2
        exit 2
    fi

    if [ -d "$target" ]; then
        echo "$repo already in $target. Skipping."
        return 0
    fi
    echo "Cloning $repo into $target..."
    git clone --depth 1 "$repo" "$target" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone $repo" >&2
        exit 3
    fi
}

check() {
    if ! command -v apt >/dev/null 2>&1; then
        echo "apt not found. Exiting."
        exit 5
    fi
}

update() {
    echo "Updating apt..."
    sudo apt update -qq >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update apt" >&2
        exit 6
    fi
}

get_package_version() {
    local package="$1"

    echo $(dpkg-query -W -f='${Version}' "$package" 2>/dev/null)
}

check_package_version() {
    local package="$1"
    local version="$2"

    local installed_version
    installed_version=$(get_package_version "$package")

    if [ -z "$installed_version" ]; then
        return 1 
    fi

    dpkg --compare-versions "$installed_version" ge "$version"
    return $?
}

install_package() {
    local package="$1"

    sudo apt install -y "$package" >/dev/null 2>&1
    return $?
}

install() {
    local package="$1"
    local version="$2"

    if [ -z "$package" ] || [ -z "$version" ]; then
        echo "Error: not enough arguments passed, install requires 2 arguments" >&2
        exit 1
    fi

    if [ "${3-}" ]; then
        echo "Error: too many arguments passed, install requires 2 arguments" >&2
        exit 2
    fi

    if check_package_version "$package" "$version"; then
        echo "$package >= $version is already installed. Skipping."
        return 0
    fi

    echo "Installing $package version $version..."
    if ! install_package "$package"; then
        echo "Error: failed to install $package version $version" >&2
        exit 3
    fi

    if ! check_package_version "$package" "$version"; then
        local installed_version
        installed_version=$(get_package_version "$package")
        echo "Error: installed version $installed_version does not match requested version $version" >&2
        exit 4
    fi
}

npm_install() {
    local package="$1"
    local version="$2"
    local cmd="${3:-$package}"

    if [ -z "$package" ] || [ -z "$version" ]; then
        echo "Error: not enough arguments passed, npm_install requires 2 arguments" >&2
        exit 1
    fi

    if [ "${4-}" ]; then
        echo "Error: too many arguments passed, npm_install requires 2 arguments" >&2
        exit 2
    fi
    
    if [ -z "$cmd" ]; then
        cmd=$package
    fi


    local installed_version
    installed_version=$(npm list -g --depth=0 "$package" | grep "$package@" | awk -F@ '{print $2}')

    if [ -n "$installed_version" ] && [ "$installed_version" = "$version" ]; then 
        echo "$package = $version is already installed. Skipping." # TODO: do >=
        return
    fi

    echo "Installing $package version $version..."
    sudo npm install -g $package@$version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: failed to install $package version $version" >&2
        exit 3
    fi
}

main() {
    check
    update

    install ripgrep "14.1.0"
    install fd-find "9.0.0-1"
    install nodejs "18.19.1"
    npm_install tree-sitter-cli "0.25.9" tree-sitter
    npm_install deno "2.5.1"
    install neovim "0.11.0"

    clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
    install tmux "3.4"
}

main

