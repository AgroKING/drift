#!/bin/bash
# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="$(dirname "$DIR")"

echo "Running Drift Backend Agent..."
# Run the python agent with any passed arguments, defaulting to --live if none provided
if [ "$#" -eq 0 ]; then
  set -- scan --live
elif [[ "$1" == --* ]]; then
  set -- scan "$@"
fi

uv run --directory "$ROOT_DIR/backend" python -m drift_agent "$@"
