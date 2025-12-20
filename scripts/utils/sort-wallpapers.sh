#!/bin/bash
# Wrapper to run sort-wallpapers.py with the venv
SCRIPT_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/.venv/bin/activate"
python "$SCRIPT_DIR/utils/sort-wallpapers.py" "$@"
