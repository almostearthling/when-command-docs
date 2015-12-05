#!/bin/bash
find . -type f -name '*~' -exec echo '{}' \; -exec trash '{}' \;
