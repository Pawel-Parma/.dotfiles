alias python="python3"
math() {
    if [[ $# -ge 1 ]]; then
        python -c "from math import *; from fractions import Fraction; F = Fraction; print(eval('$*'))"
    fi
    return $?
}

