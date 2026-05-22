#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root" || exit 1

status=0

printf '== bash syntax ==\n'
if ! bash -n lib/*.sh tests/*.sh tests/*.bash; then
    status=1
fi

printf '== tests ==\n'
if ! bash tests/run.sh; then
    status=1
fi

printf '== shellcheck ==\n'
if command -v shellcheck >/dev/null 2>&1; then
    if ! shellcheck -x -P "$repo_root/lib" -P "$repo_root/tests" lib/*.sh tests/*.sh tests/*.bash; then
        status=1
    fi
elif [[ "${SHLIB_REQUIRE_SHELLCHECK:-}" == "1" ]]; then
    printf 'shellcheck is required but was not found\n' >&2
    status=1
else
    printf 'shellcheck not found; skipping lint\n'
fi

exit "$status"
