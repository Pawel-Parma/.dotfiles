alias gl="git log --all --graph --pretty=format:'%C(green)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
alias ga="git add"
alias gap="git add --patch"
alias gd="git diff"
alias gds="git diff --staged"
alias gp="git push"
alias gpu="git pull"
alias gcl="git clone"
gs() {
    local gstatus="$(git -c color.status=always status)"
    local gwidth=$(( $(tput cols) < 120 ? $(tput cols) - 1 : 120 ))
    local gdiff="$(git diff --stat --color=always --stat-width="$gwidth")"
    $HOME/.config/git/gjoin.py "$gstatus" "$gdiff"
}
alias gsr="git status"
alias gb="git branch"
alias gsw="git switch"
alias gf="git fetch"
alias gc="git commit"
alias gw="git worktree"

