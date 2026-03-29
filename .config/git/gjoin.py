#!/usr/bin/python3
import sys

GREEN = "\033[32m"
RED = "\033[31m"
BLUE    = "\033[34m"
MAGENTA = "\033[35m"
RESET = "\033[0m"

def main():
    if len(sys.argv) < 3:
        print("Usage: ./gjoin.py \"$(git -c color.status=always status -sb)\" \"$(git diff --stat --color=always)\"")
        return

    status = sys.argv[1].splitlines()
    diff= sys.argv[2].splitlines()
    output = status[0] + "\n"

    for i in range(len(diff) - 1):
        output += status[i + 1]
        output += diff[i][diff[i][1:].index(" ") + 1:] + "\n"

    output += "\n".join(status[len(diff):]) + "\n"

    f, i, d = [int(s) for s in diff[-1][1:].split() if s.isdigit()]
    output += f"\n{BLUE}{f}{RESET} files changed, {GREEN}{i}{RESET} insertions({GREEN}+{RESET}), {RED}{d}{RESET} deletions({RED}-{RESET}), {MAGENTA}{i + d}{RESET} changes"
    print(output)

if __name__ == "__main__":
    main()
