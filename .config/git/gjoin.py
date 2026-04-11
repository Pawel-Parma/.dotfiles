#!/usr/bin/python3
import sys

R = RED = "\033[31m"
G = GREEN = "\033[32m"
Y = YELLOW = "\033[33m"
B = BLUE = "\033[34m"
M = MAGENTA = "\033[35m"
RE = RESET = "\033[0m"

INFO_MSG = f"\n{B}{{}}{RE} files changed, {Y}{{}}{RE} files untracked, {G}{{}}{RE} insertions({G}+{RE}), {R}{{}}{RE} deletions({R}-{RE}), {M}{{}}{RE} changes"


def main(status: list[str], diff: list[str]):
    untracked = len(status) - len(diff[:-1]) - 1
    changed = 0
    insertions = 0
    deletions = 0

    # TODO: add matching from diff to status, as gitmodules break the script
    output: list[str] = [status[0]]
    if len(diff) != 0:
        for i in range(len(diff) - 1):
            file_track = status[i + 1]
            file_status = diff[i][diff[i][1:].index(" ") + 1:]
            output.append(file_track + file_status)

        changed, insertions, deletions, *_ = [int(s) for s in diff[-1][1:].split() if s.isdigit()] + [0] * 3

    output.extend(status[len(diff[:-1]) + 1:])
    msg = INFO_MSG.format(changed, untracked, insertions, deletions, insertions + deletions)
    output.append(msg)

    print("\n".join(output))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: ./gjoin.py \"$(git status)\" \"$(git diff)\"")
        exit()

    status = sys.argv[1].splitlines()
    diff= sys.argv[2].splitlines()
    main(status, diff)

