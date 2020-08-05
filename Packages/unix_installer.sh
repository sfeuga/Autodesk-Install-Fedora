#!/bin/bash

ABSPATH=$(readlink -f "$0")
ABSDIR=$(dirname "$ABSPATH")

cd "$ABSDIR"
python "$ABSDIR/unix_installer.py" 2020 linux #silent
exit 0
