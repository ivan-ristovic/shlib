#!/usr/bin/env bash
set -u

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0

for test_file in "$test_dir"/*_test.sh; do
    printf '== %s ==\n' "$(basename "$test_file")"
    if ! bash "$test_file"; then
        status=1
    fi
done

exit "$status"
