#!/bin/sh
find . -path ./.local/share/Trash -prune \
    -o -type f -name '*~' \
    -exec echo '{}' \; \
    -exec trash -f '{}' \;
