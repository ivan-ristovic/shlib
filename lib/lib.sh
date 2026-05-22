#!/bin/bash

for __src in "$SHLIB_ROOT"/*.sh; do
    if [ "$(basename "$__src")" != "lib.sh" ]; then
        # shellcheck source=/dev/null
        source "$__src"
    fi
done
unset __src
