git submodule update --init --recursive
git submodule foreach 'git checkout main && git pull'
stow -t ~ .

